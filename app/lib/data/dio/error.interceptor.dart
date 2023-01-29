import 'package:dio/dio.dart';
import 'package:sudonym.models/index.dart';

class ErrorInterceptor extends Interceptor {
  ErrorInterceptor();

  @override
  onError(DioError err, ErrorInterceptorHandler handler) {
    if (err.response?.data is Map && err.response?.data['code'] != null) {
      err.response!.data = parseError(err.response!.data);
      return handler.next(err);
    }
    return handler.next(err);
  }
}

dynamic parseError(dynamic data) {
  if (data['code'] == LNURLProtocolError.staticCode) {
    return LNURLProtocolError.fromJson(data);
  } else if (data['code'] == BalanceLowError.staticCode) {
    return BalanceLowError.fromJson(data);
  }
  return data;
}
