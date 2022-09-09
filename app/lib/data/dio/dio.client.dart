import 'package:dio/dio.dart';
import 'package:flutter_loggy_dio/flutter_loggy_dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym/config/config.dart';
import 'dio.interceptor.dart';

@module
abstract class RegisterModule {
  @lazySingleton
  Dio dio(Config config) {
    Dio dio = Dio(BaseOptions(baseUrl: '${config.apiUrl}:${config.apiPort}'))
      ..interceptors.add(LoggyDioInterceptor())
      ..interceptors.add(AuthInterceptor());

    // // //@todo: check bad certificate
    // // (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
    // //     (HttpClient client) {
    // //   client.badCertificateCallback =
    // //       (X509Certificate cert, String host, int port) => true;
    //   return client;
    // };
    return dio;
  }
}
