import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../injection.dart';

@LazySingleton(as: CurrencyRepository, env: Env.allButMock)
class CurrencyRepositoryImpl extends CurrencyRepository {
  CurrencyRepositoryImpl(Dio dio) : super(dio);

  @override
  Future<CurrencyResponse> getRate(
      String fromCurrency, String toCurrency, num amount, DateTime time) {
    return dio.get('/currency', queryParameters: {
      "fromCurrency": fromCurrency,
      "toCurrrency": toCurrency,
      "amount": amount,
      "time": time
    }).then((value) {
      print(value);
      return value as CurrencyResponse;
    });
  }
}

abstract class CurrencyRepository {
  Dio dio;
  Future<CurrencyResponse> getRate(
      String fromCurrency, String toCurrency, num amount, DateTime time);
  CurrencyRepository(this.dio);
}

class CurrencyResponse {
  late num amount;
}
