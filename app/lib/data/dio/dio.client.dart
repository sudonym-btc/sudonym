import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym/config/config.dart';
import 'dio.interceptor.dart';

@module
abstract class RegisterModule {
  @lazySingleton
  Dio dio(Config config) {
    return Dio(
        BaseOptions(baseUrl: config.apiUrl + ':' + config.apiPort.toString()))
      ..interceptors.add(AuthInterceptor());
  }
}
