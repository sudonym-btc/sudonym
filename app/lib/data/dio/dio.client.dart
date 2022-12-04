import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:sudonym/config/index.dart';
import 'package:sudonym/data/dio/auth.interceptor.dart';

@module
abstract class RegisterModule {
  @lazySingleton
  Dio dio(Config config) {
    Dio dio = Dio(
      BaseOptions(baseUrl: '${config.apiUrl}:${config.apiPort}'),
    )
      ..interceptors.add(PrettyDioLogger(
          requestHeader: false,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90))
      ..interceptors.add(AuthInterceptor());
    // ..interceptors.add(cacheInterceptor);
    return dio;
  }
}
