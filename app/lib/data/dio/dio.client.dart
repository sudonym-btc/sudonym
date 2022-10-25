import 'package:dio/dio.dart';
import 'package:flutter_loggy_dio/flutter_loggy_dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym/config/config.dart';
import 'cache.interceptor.dart';
import 'auth.interceptor.dart';

@module
abstract class RegisterModule {
  @lazySingleton
  Dio dio(Config config) {
    Dio dio = Dio(BaseOptions(baseUrl: '${config.apiUrl}:${config.apiPort}'))
      ..interceptors.add(LoggyDioInterceptor())
      ..interceptors.add(AuthInterceptor())
      ..interceptors.add(cacheInterceptor);
    return dio;
  }
}
