import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/types/currency.dart';

import 'package:sudonym/injection.dart';

@LazySingleton(as: CurrencyRepository, env: Env.allButMock)
class CurrencyRepositoryImpl extends CurrencyRepository {
  CurrencyRepositoryImpl(Dio dio) : super(dio);

  @override
  Future<CurrencyResponse> getRate(
      String fromCurrency, String toCurrency, num amount, DateTime? time) {
    return dio.get('/currency', queryParameters: {
      'fromCurrency': fromCurrency,
      'toCurrency': toCurrency,
      'amount': amount,
      'time': time
    }).then((value) {
      return CurrencyResponse(value.data['amount']);
    });
  }
}

abstract class CurrencyRepository {
  Dio dio;
  Future<CurrencyResponse> getRate(
      String fromCurrency, String toCurrency, num amount, DateTime? time);
  CurrencyRepository(this.dio);
}
