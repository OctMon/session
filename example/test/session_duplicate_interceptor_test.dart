import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:session/session.dart';
import 'package:flutter_test/flutter_test.dart';

const _deadline = Duration(seconds: 2);

class _PendingRequest {
  final RequestOptions options;
  final response = Completer<ResponseBody>();

  _PendingRequest(this.options);

  void complete([int statusCode = 200]) {
    response.complete(ResponseBody.fromString('{}', statusCode, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType]
    }));
  }
}

class _ControlledAdapter implements HttpClientAdapter {
  final requests = StreamController<_PendingRequest>();

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future? cancelFuture) {
    final request = _PendingRequest(options);
    requests.add(request);
    return request.response.future;
  }

  @override
  void close({bool force = false}) {
    requests.close();
  }
}

void main() {
  setUp(() {
    Config.logEnable = false;
    Config.catchLogEnable = false;
  });

  group('DioInterceptor', () {
    late Dio dio;
    late StreamIterator<_PendingRequest> requests;

    setUp(() {
      final adapter = _ControlledAdapter();
      requests = StreamIterator(adapter.requests.stream);
      dio = Dio(BaseOptions(baseUrl: 'http://localhost'))
        ..httpClientAdapter = adapter
        ..interceptors.add(DioInterceptor());
    });

    tearDown(() async {
      await requests.cancel();
      dio.close(force: true);
    });

    Future<_PendingRequest> nextRequest() async {
      expect(await requests.moveNext().timeout(_deadline), isTrue);
      return requests.current;
    }

    final isCancelled = isA<DioException>()
        .having((error) => error.type, 'type', DioExceptionType.cancel);

    test('duplicates finish without releasing the original request', () async {
      final first = dio.get('/duplicates');
      final pending = await nextRequest();

      // A second duplicate must also be rejected while the original is pending.
      for (var i = 0; i < 2; i++) {
        await expectLater(
            dio.get('/duplicates').timeout(_deadline), throwsA(isCancelled));
      }

      pending.complete();
      expect((await first.timeout(_deadline)).statusCode, 200);

      final retry = dio.get('/duplicates');
      (await nextRequest()).complete();
      expect((await retry.timeout(_deadline)).statusCode, 200);
    });

    test('HTTP errors release the request for retry', () async {
      final first = dio.get('/failure');
      final failed = expectLater(
          first.timeout(_deadline),
          throwsA(isA<DioException>().having(
              (error) => error.type, 'type', DioExceptionType.badResponse)));
      (await nextRequest()).complete(500);
      await failed;

      final retry = dio.get('/failure');
      (await nextRequest()).complete();
      await retry.timeout(_deadline);
    });

    test('caller cancellation releases the request for retry', () async {
      final token = CancelToken();
      final first = dio.get('/cancel', cancelToken: token);
      final cancelled =
          expectLater(first.timeout(_deadline), throwsA(isCancelled));
      final pending = await nextRequest();
      expect(pending.options.cancelToken, same(token));
      token.cancel('user cancelled');
      await cancelled;

      final retry = dio.get('/cancel');
      final retryPending = await nextRequest();
      // A late completion of the cancelled transport cannot release the retry.
      pending.complete();
      await expectLater(
          dio.get('/cancel').timeout(_deadline), throwsA(isCancelled));
      retryPending.complete();
      await retry.timeout(_deadline);
    });

    test('different query parameters can run concurrently', () async {
      final first = dio.get('/query', queryParameters: {'page': 1});
      final firstPending = await nextRequest();
      final second = dio.get('/query', queryParameters: {'page': 2});
      final secondPending = await nextRequest();
      firstPending.complete();
      secondPending.complete();
      await Future.wait([first, second]).timeout(_deadline);
    });
  });

  for (final global in [true, false]) {
    test('Session returns a cancelled Result (global=$global)', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final requests = StreamIterator(server);
      addTearDown(() async {
        await requests.cancel();
        await server.close(force: true);
      });
      var resultCount = 0;
      final config = Config(
          baseUrl: 'http://127.0.0.1:${server.port}',
          globalDuplicateInterceptor: global);
      Session newSession() => Session(
          config: config,
          onResult: (result) {
            resultCount++;
            return result;
          });

      final first = newSession().get('/session', duplicateInterceptor: !global);
      expect(await requests.moveNext().timeout(_deadline), isTrue);
      final original = requests.current;
      try {
        for (var i = 0; i < 2; i++) {
          final duplicate = await newSession()
              .get('/session', duplicateInterceptor: !global)
              .timeout(_deadline);
          expect(duplicate.valid, isFalse);
          expect(duplicate.error?.type, DioExceptionType.cancel);
          expect(duplicate.message, config.errorCancel);
        }
      } finally {
        original.response.headers.contentType = ContentType.json;
        original.response.write('{"code":"0","data":{}}');
        await original.response.close();
      }
      expect((await first.timeout(_deadline)).valid, isTrue);
      expect(resultCount, 3);

      final retry = newSession().get('/session', duplicateInterceptor: !global);
      expect(await requests.moveNext().timeout(_deadline), isTrue);
      requests.current.response.headers.contentType = ContentType.json;
      requests.current.response.write('{"code":"0","data":{}}');
      await requests.current.response.close();
      expect((await retry.timeout(_deadline)).valid, isTrue);
      expect(resultCount, 4);
    });
  }
}
