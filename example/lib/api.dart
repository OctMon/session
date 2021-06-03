import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:session/session.dart';

export 'package:session/session.dart' show Result;

Config configAPI(String baseURL) {
  return Config(
    baseUrl: baseURL ?? "https://www.httpbin.org/",
//    proxy: 'PROXY localhost:8888',
    connectTimeout: 10,
    receiveTimeout: 10,
  );
}

SessionInterceptorSendHandler _onRequest = (options) async {
  var headers = {
    'os': Platform.isIOS ? 'ios' : 'android',
  };
  options.headers.addAll(headers);
  // if (UserStore.store.getState().isLogin) {
  //   options.headers['id'] = UserStore.store.getState().user.userId;
  // }
  // options.contentType = Headers.formUrlEncodedContentType;
  // options.responseType = ResponseType.plain;
  return options;
};

/// 响应结果拦截处理
Result _onValidResult(Result result, bool validResult, BuildContext context) {
  // 拦截处理一些错误
  if (validResult) {
    switch (result.code) {
      case "${-3}":
        // do something...
        break;
      case "${-2}":
        // do something...
        break;
    }
  }
  return result;
}

///
/// 发送请求并解析远程服务器返回的result对应的实体类型
///
/// baseUrl: 主机地址
/// path: 请求路径
/// queryParameters: URL携带请求参数
/// connectTimeout: 超时时间
/// validResult: 是否检验返回结果
/// context: 上下文
///
Future<Result> getAPI(
    {String baseUrl,
    String path = '',
    Map<String, dynamic> queryParameters,
    int connectTimeout,
    bool validResult = true,
    BuildContext context}) async {
  return requestAPI(
      baseUrl: baseUrl,
      path: path,
      queryParameters: queryParameters,
      options: Options(method: 'get'),
      connectTimeout: connectTimeout,
      validResult: validResult,
      context: context);
}

///
/// 发送请求并解析远程服务器返回的result对应的实体类型
///
/// baseUrl: 主机地址
/// path: 请求路径
/// data: 请求参数
/// connectTimeout: 超时时间
/// validResult: 是否检验返回结果
/// context: 上下文
///
Future<Result> postAPI(
    {String baseUrl,
    String path = '',
    data,
    int connectTimeout,
    bool validResult = true,
    BuildContext context}) async {
  return requestAPI(
      baseUrl: baseUrl,
      path: path,
      data: data,
      options: Options(method: 'post'),
      connectTimeout: connectTimeout,
      validResult: validResult,
      context: context);
}

///
/// 发送请求并解析远程服务器返回的result对应的实体类型
///
/// baseUrl: 主机地址
/// path: 请求路径
/// data: 请求参数
/// validResult: 是否检验返回结果
/// context: 上下文
///
Future<Result> requestAPI(
    {String baseUrl,
    String path = '',
    data,
    Map<String, dynamic> queryParameters,
    Options options,
    int connectTimeout,
    bool validResult = true,
    BuildContext context}) async {
  Session session = Session(
    config: configAPI(baseUrl),
    onRequest: _onRequest,
  );
  Result result = await session.request(
    path,
    data: data,
    queryParameters: queryParameters,
    options: options,
    connectTimeout: connectTimeout,
  );
  return _onValidResult(result, validResult, context);
}
