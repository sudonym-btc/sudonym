import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor();

  @override
  onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (FirebaseAuth.instance.currentUser != null) {
      String bearer = await FirebaseAuth.instance.currentUser!.getIdToken();
      options.headers["x-access-token"] = bearer;
    }
    return handler.next(options);
  }
}
