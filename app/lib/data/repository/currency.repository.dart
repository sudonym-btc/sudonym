import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:sudonym.models/types/currency.dart';
import 'package:sudonym/data/dio/cache.interceptor.dart';

import 'package:sudonym/injection.dart';

@LazySingleton(as: CurrencyRepository, env: Env.allButMock)
class CurrencyRepositoryImpl extends CurrencyRepository {
  CurrencyRepositoryImpl(Dio dio) : super(dio);

  @override
  Future<CurrencyResponse> getRate(
      {required String fromCurrency,
      required String toCurrency,
      num amount = 1,
      DateTime? time}) {
    return dio.get('/currency', queryParameters: {
      'fromCurrency': fromCurrency,
      'toCurrency': toCurrency,
      'time': time
    }).then((value) {
      return CurrencyResponse(value.data['amount'] * amount);
    });
  }
}

abstract class CurrencyRepository {
  Dio dio;
  Future<CurrencyResponse> getRate(
      {required String fromCurrency,
      required String toCurrency,
      num amount,
      DateTime? time});
  CurrencyRepository(this.dio);
}

String getCurrencySymbol(String currency) {
  if (currency == 'BTC') {
    return '丰';
  }
  var format =
      NumberFormat.simpleCurrency(locale: Platform.localeName, name: currency);
  return format.currencySymbol;
}
