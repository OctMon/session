library session;

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/adapter.dart';

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

  /// findProxy
  ///
  /// If you need Charles local interception
  ///
  /// please set proxy = 'PROXY localhost:8888'
  final String proxy;

  /// Sets a callback that will decide whether to accept a secure connection
  /// with a server certificate that cannot be authenticated by any of our
  /// trusted root certificates.
  final bool Function(X509Certificate cert, String host, int port)?
      badCertificateCallback;

  /// second
  final int connectTimeout;

  /// second
  final int receiveTimeout;

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
  final String? errorOther;

  Config(
      {this.baseUrl = '',
      this.proxy = '',
      this.badCertificateCallback,
      this.connectTimeout = 10,
      this.receiveTimeout = 10,
      this.code = 'code',
      this.data = 'data',
      this.list = 'data/list',
      this.message = 'message',
      this.validCode = '0',
      this.errorTimeout = '网络请求超时',
      this.errorResponse = '服务器错误，请稍后重试',
      this.errorCancel = '请求被取消了',
      this.errorOther = '网络连接出错，请检查网络连接'});
}

enum ErrorType {
  /// It occurs when timeout.
  timeout,

  /// When the server response, but with a incorrect status, such as 404, 503...
  response,

  /// When the request is cancelled, dio will throw a error with this type.
  cancel,

  /// Default error type, Some other Error. In this case, you can
  /// read the DioError.error if it is not null.
  other,
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

typedef SessionInterceptorSendHandler = void Function(RequestOptions options);
typedef SessionInterceptorSuccessHandler = dynamic Function(Result result);

class Session {
  final Config config;
  final SessionInterceptorSendHandler? onRequest;
  final SessionInterceptorSuccessHandler? onResult;

  Session({required this.config, this.onRequest, this.onResult});

  Future<Result> request(
    String path, {
    Map? data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _options = BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: config.connectTimeout * 1000,
        receiveTimeout: config.receiveTimeout * 1000);
    final Dio _dio = Dio(
      _options,
    )..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.next(options);
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
      (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (client) {
        if (config.proxy.isNotEmpty) {
          client.findProxy = (uri) {
            return config.proxy;
          };
        }
        if (config.badCertificateCallback != null) {
          client.badCertificateCallback = config.badCertificateCallback;
        }
      };
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
        error: ErrorType.response);
    try {
      response = await _dio.request(path,
          data: data,
          queryParameters: queryParameters,
          cancelToken: cancelToken,
          options: options,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress);
    } on DioError catch (error) {
      ErrorType errorType = ErrorType.other;
      String message = error.message;
      switch (error.type) {
        case DioErrorType.other:
          if (config.errorOther != null) {
            message = config.errorOther!;
          }
          errorType = ErrorType.other;
          break;
        case DioErrorType.response:
          if (config.errorResponse != null) {
            message = config.errorResponse!;
          }
          errorType = ErrorType.response;
          break;
        case DioErrorType.cancel:
          if (config.errorCancel != null) {
            message = config.errorCancel!;
          }
          errorType = ErrorType.cancel;
          break;
        default:
          if (config.errorTimeout != null) {
            message = config.errorTimeout!;
          }
          errorType = ErrorType.timeout;
      }
      result = Result(
          response: error.response,
          body: (error.response?.data is Map) ? error.response?.data : {},
          code: error.response?.statusCode.toString() ?? '',
          data: {},
          list: [],
          message: message,
          error: errorType);
    } catch (error) {
      if (Config.logEnable) {
        print(error);
      }
    }
    Map body = {};
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
