import 'dart:math';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym/data/repository/currency.repository.dart';
import 'package:sudonym/injection.dart';

@Injectable(as: CurrencyRepository, env: [Env.mock])
class MockCurrencyRepository implements CurrencyRepository {
  MockCurrencyRepository(this.dio);

  @override
  Dio dio;

  @override
  Future<CurrencyResponse> getRate(
      String fromCurrency, String toCurrency, num amount, DateTime time) async {
    CurrencyResponse c = CurrencyResponse();
    c.amount = Random().nextDouble() * amount;
    return c;
  }
}
