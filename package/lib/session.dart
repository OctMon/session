library session;

import 'dart:convert';

import 'package:dio/dio.dart';

class Config {
  /// Request base url,
  ///
  /// it can contain sub path, like: "https://www.google.com/api/".
  final String baseUrl;

  /// findProxy
  ///
  /// If you need Charles local interception
  ///
  /// please set proxy = 'PROXY localhost:8888'
  final String proxy;

  /// second
  final int connectTimeout;

  /// second
  final int receiveTimeout;

  final String code;
  final String data;
  final String list;
  final String message;

  final String validCode;

  Config(
      {this.baseUrl,
      this.proxy = '',
      this.connectTimeout = 10,
      this.receiveTimeout = 10,
      this.code = 'code',
      this.data = 'data',
      this.list = 'data/list',
      this.message = 'message',
      this.validCode = '0'});
}

/// A Result.
class Result {
  final Response response;
  final Map body;
  final String code;
  final String message;
  final Map data;
  final List list;
  final bool valid;
  dynamic _model;
  List _models;

  Result(
      {this.response,
      this.body,
      this.code = '',
      this.message = '',
      this.data,
      this.list,
      this.valid = false});

  Result fill(model) {
    this._model = model;
    return this;
  }

  Result fillList(models) {
    this._models = models;
    return this;
  }

  dynamic get model {
    return _model;
  }

  List get models {
    return _models;
  }
}

class Session {
  final Config config;
  final InterceptorSendCallback onRequest;
  final void Function(Result result) onResult;

  Session({this.config, this.onRequest, this.onResult});

  Future<Result> request(
    String path, {
    data,
    Map<String, dynamic> queryParameters,
    CancelToken cancelToken,
    Options options,
    ProgressCallback onSendProgress,
    ProgressCallback onReceiveProgress,
  }) async {
    final _options = BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: config.connectTimeout * 1000,
        receiveTimeout: config.receiveTimeout * 1000);
    final Dio _dio = Dio(
      _options,
    )
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: onRequest,
          onError: (DioError error) {
            String message = error.message;
            switch (error.type) {
              case DioErrorType.DEFAULT:
                message = '网络未连接';
                break;
              case DioErrorType.RESPONSE:
                message = '服务器错误，请稍后重试';
                break;
              default:
                message = '网络请求超时';
            }
            return Result(body: {}, data: {}, list: [], message: message);
          },
        ),
      )
      ..interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
        ),
      );
    if (config.proxy.isNotEmpty) {
      (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (client) {
        client.findProxy = (uri) {
          return config.proxy;
        };
      };
    }
    Response response = await _dio.request(path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress);
    Result result;
    Map body;
    if (response.data is Map) {
      body = response.data ?? {};
    } else if (response.data is String) {
      body = json.decode(response.data);
    }
    if (body is Map) {
      var code = '';
      var data = {};
      var list = [];
      var message = '';
      try {
        code = _getMap(body, config.code).toString();
        data = _getMap(body, config.data);
        list = _getMap(body, config.list);
        message = _getMap(body, config.message);
      } catch (e) {
        print(e);
      }
      result = Result(
          response: response,
          body: body,
          code: code,
          data: data,
          list: list,
          message: message,
          valid: code == config.validCode);
    } else {
      result = response.data;
    }
    if (onResult != null) {
      onResult(result);
    }
    return result;
  }

  Future<Result> post(
    String path, {
    data,
  }) async {
    return request(path, data: data, options: Options(method: 'post'));
  }

  dynamic _getMap(dynamic map, String key) {
    List keys = key.split('/');
    while (keys.length > 1) {
      var _map = map[keys.first];
      keys.removeAt(0);
      return _getMap(_map, keys.join('/'));
    }
    if (map is Map) {
      return map[keys.first];
    }
    if (map is List) {
      return map;
    }
    return null;
  }
}
