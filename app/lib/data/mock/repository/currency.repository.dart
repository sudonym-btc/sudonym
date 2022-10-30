import 'dart:math';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';

@Injectable(as: CurrencyRepository, env: [Env.mock])
class MockCurrencyRepository implements CurrencyRepository {
  MockCurrencyRepository(this.dio);

  @override
  Dio dio;

  @override
  Future<CurrencyResponse> getRate(
      {required String fromCurrency,
      required String toCurrency,
      num amount = 1,
      DateTime? time}) async {
    CurrencyResponse c = CurrencyResponse(Random().nextDouble() * amount);
    return c;
  }
}
