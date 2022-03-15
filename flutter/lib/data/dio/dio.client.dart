import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'dio.interceptor.dart';

// @Singleton(as: Dio)
// class CustomDio {
//   @FactoryMethod
// }
// final dio = Dio()
//   ..options.baseUrl = 'https://api.sudonym.app'
//   ..interceptors.add(AuthInterceptor());

@module
abstract class RegisterModule {
  // You can register named preemptive types like follows
  @Named("BaseUrl")
  String get baseUrl => 'My base url';

  // url here will be injected
  @lazySingleton
  Dio dio(@Named('BaseUrl') String url) =>
      Dio(BaseOptions(baseUrl: url))..interceptors.add(AuthInterceptor());
}
