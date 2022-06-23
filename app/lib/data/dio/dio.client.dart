import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym/config/config.dart';
import 'dio.interceptor.dart';

@module
abstract class RegisterModule {
  @lazySingleton
  Dio dio(Config config) {
    print(config);
    print("DIO" + config.apiUrl);
    return Dio(BaseOptions(baseUrl: config.apiUrl))
      ..interceptors.add(AuthInterceptor());
  }
}
