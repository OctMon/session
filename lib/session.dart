library session;

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio/src/adapters/io_adapter.dart';

bool _debugFlag = false;

/// is app run a debug mode.
bool _isDebug() {
  /// Assert statements have no effect in production code;
  /// they’re for development only. Flutter enables asserts in debug mode.
  assert(() {
    _debugFlag = true;
    return _debugFlag;
  }());
  return _debugFlag;
}

class Config {
  static bool logEnable = _isDebug();

  /// Request base url,
  ///
  /// it can contain sub path, like: "https://www.google.com/api/".
  final String baseUrl;

  /// createHttpClient: () {
  ///   // Don't trust any certificate just because their root cert is trusted.
  ///   final client =
  ///       HttpClient(context: SecurityContext(withTrustedRoots: false));
  ///   // You can test the intermediate / root cert here. We just ignore it.
  ///   client.badCertificateCallback = (cert, host, port) => true;
  ///   // Config the client.
  ///   client.findProxy = (uri) {
  ///     // Forward all request to proxy "localhost:8888".
  ///     // Be aware, the proxy should went through you running device,
  ///     // not the host platform.
  ///     return "PROXY localhost:8888";
  ///   };
  CreateHttpClient? createHttpClient;

  /// Sets a callback that will decide whether to accept a secure connection
  /// with a server certificate that cannot be authenticated by any of our
  /// trusted root certificates.
  /// badCertificateCallback: (cert, String host, int port) {
  ///   return true;
  /// },
  final ValidateCertificate? badCertificateCallback;

  /// second
  final Duration connectTimeout;

  /// second
  final Duration receiveTimeout;

  final String code;
  final String data;
  final String list;
  final String message;

  final String validCode;

  /// It occurs when timeout
  /// If you set null to read the error returned by dio
  /// otherwise read the user-defined error message
  final String? errorTimeout;

  /// When the server response, but with a incorrect status, such as 404, 503...
  /// If you set null to read the error returned by dio
  /// otherwise read the user-defined error message
  final String? errorResponse;

  /// When the request is cancelled, dio will throw a error with this type.
  /// If you set null to read the error returned by dio
  /// otherwise read the user-defined error message
  final String? errorCancel;

  /// Default error type, Some other Error. In this case, you can
  /// read the DioError.error if it is not null.
  /// If you set null to read the error returned by dio
  /// otherwise read the user-defined error message
  final String? errorUnknown;

  Config(
      {this.baseUrl = '',
      this.createHttpClient,
      this.badCertificateCallback,
      this.connectTimeout = const Duration(seconds: 10),
      this.receiveTimeout = const Duration(seconds: 10),
      this.code = 'code',
      this.data = 'data',
      this.list = 'data/list',
      this.message = 'message',
      this.validCode = '0',
      this.errorTimeout = '网络请求超时',
      this.errorResponse = '服务器错误，请稍后重试',
      this.errorCancel = '请求被取消了',
      this.errorUnknown = '网络连接出错，请检查网络连接'});
}

enum ErrorType {
  /// It occurs when timeout.
  timeout,

  /// When the server response, but with a incorrect status, such as 404, 503...
  response,

  /// When the request is cancelled, dio will throw a error with this type.
  cancel,

  /// Default error type, Some other [Error]. In this case, you can use the
  /// [DioExceptionType.error] if it is not null.
  unknown,
}

/// A Result.
class Result {
  final Response? response;
  final Map body;
  final String code;
  final String message;
  final Map data;
  final List list;
  final bool valid;
  final ErrorType? error;
  dynamic _model;
  List _models = [];

  Result(
      {this.response,
      this.body = const {},
      this.code = '',
      this.message = '',
      this.data = const {},
      this.list = const [],
      this.error,
      this.valid = false});

  merge(Result other) {
    Result result = Result(
      response: other.response ?? response,
      body: other.body.isNotEmpty ? other.body : body,
      code: other.code.isNotEmpty ? other.code : code,
      message: other.message.isNotEmpty ? other.message : message,
      data: other.data.isNotEmpty ? other.data : data,
      list: other.list.isNotEmpty ? other.list : list,
      error: other.error ?? error,
      valid: other.valid ? other.valid : valid,
    );
    result.fill(_model);
    result.fillList(_models);
    return result;
  }

  fill(model) => this._model = model;

  fillList(models) => this._models = models;

  fillModel<T>(T Function(Map json) onModel) {
    try {
      _model = onModel(data);
    } catch (e) {
      if (Config.logEnable) {
        print(e);
      }
    }
  }

  fillModels<T>(T Function(Map json) onModels) {
    try {
      if (list.length > 0) {
        _models = list.map((v) => onModels(v)).toList();
      }
    } catch (e) {
      if (Config.logEnable) {
        print(e);
      }
    }
  }

  fillMap<T>(T Function(Map json) onMap, {dynamic map}) {
    try {
      if (map != null) {
        if (map is List) {
          _models = map.map((v) => onMap(v)).toList();
        } else if (map is Map) {
          _model = onMap(map);
        }
      } else if (list.length > 0) {
        _models = list.map((v) => onMap(v)).toList();
      } else if (data.isNotEmpty == true) {
        _model = onMap(data);
      } else {
        _model = onMap(body);
      }
    } catch (e) {
      if (Config.logEnable) {
        print(e);
      }
    }
  }

  dynamic get model {
    return _model;
  }

  List get models {
    return _models;
  }

  bool validWith(String code) {
    return this.code == code;
  }
}

typedef SessionInterceptorSendHandler = dynamic Function(
    RequestOptions options);
typedef SessionInterceptorSuccessHandler = dynamic Function(Result result);

class Session {
  final Config config;
  final SessionInterceptorSendHandler? onRequest;
  final SessionInterceptorSuccessHandler? onResult;

  Session({required this.config, this.onRequest, this.onResult});

  Future<Result> request(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    Duration? connectTimeout,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _options = BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout:
          connectTimeout != null ? connectTimeout : config.connectTimeout,
      receiveTimeout: config.receiveTimeout,
    );
    final Dio _dio = Dio(
      _options,
    )..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            return handler
                .next(onRequest != null ? await onRequest!(options) : options);
          },
        ),
      );
    if (Config.logEnable) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
        ),
      );
    }
    try {
      _dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: config.createHttpClient,
        validateCertificate: config.badCertificateCallback,
      );
    } catch (e) {
      if (Config.logEnable) {
        print(e);
      }
    }

    Response? response;
    Result result = Result(
        response: response,
        body: {},
        data: {},
        list: [],
        message: config.errorResponse ?? '',
        error: null);
    try {
      response = await _dio.request(path,
          data: data,
          queryParameters: queryParameters,
          cancelToken: cancelToken,
          options: options,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress);
    } on DioException catch (error) {
      ErrorType errorType = ErrorType.unknown;
      var message = "$error";

      if (config.errorUnknown != null) {
        message = config.errorUnknown!;
      }
      errorType = ErrorType.unknown;
      switch (error.type) {
        case DioExceptionType.connectionError:
        case DioExceptionType.badResponse:
        case DioExceptionType.badCertificate:
          if (config.errorResponse != null) {
            message = config.errorResponse!;
          }
          errorType = ErrorType.response;
          break;
        case DioExceptionType.cancel:
          if (config.errorCancel != null) {
            message = config.errorCancel!;
          }
          errorType = ErrorType.cancel;
          break;
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          if (config.errorTimeout != null) {
            message = config.errorTimeout!;
          }
          errorType = ErrorType.timeout;
          break;
        case DioExceptionType.unknown:
          break;
      }
      result = Result(
          response: error.response,
          body: (error.response?.data is Map) ? error.response?.data : {},
          code: '',
          data: {},
          list: [],
          message: message,
          error: errorType);
    } catch (error) {
      if (Config.logEnable) {
        print(error);
      }
    }
    if (result.error == null) {
      dynamic body = {};
      if (response?.data is Map) {
        body = response?.data ?? {};
      } else if (response?.data is String) {
        try {
          body = json.decode(response?.data);
        } catch (e) {
          if (Config.logEnable) {
            print(e);
          }
        }
      }
      if (body is Map) {
        var code = '';
        var data = {};
        var list = [];
        var message = '';
        try {
          code = _getMap(body, config.code).toString();
        } catch (e) {
          if (Config.logEnable) {
            print(e);
          }
        }
        try {
          data = _getMap(body, config.data) ?? {};
        } catch (e) {
          if (Config.logEnable) {
            print(e);
          }
        }
        try {
          list = _getMap(body, config.list) ?? [];
        } catch (e) {
          if (Config.logEnable) {
            print(e);
          }
        }
        try {
          message = _getMap(body, config.message) ?? '';
        } catch (e) {
          if (Config.logEnable) {
            print(e);
          }
        }
        result = Result(
            response: response,
            body: body,
            code: code,
            data: data,
            list: list,
            message: message,
            valid: code == config.validCode);
      } else if (response?.data is Result) {
        result = response?.data;
      }
    }

    if (onResult != null) {
      return onResult!(result);
    }
    return result;
  }

  Future<Result> get(
    String path, {
    Map? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return request(path,
        data: data,
        queryParameters: queryParameters,
        options: Options(method: 'get'));
  }

  Future<Result> post(
    String path, {
    Map? data,
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
