import 'dart:async';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/index.dart';

import '../../injection.dart';

@LazySingleton(as: ActionRepository, env: Env.allButMock)
class ActionRepositoryImpl extends ActionRepository {
  ActionRepositoryImpl(Dio dio) : super(dio);

  @override
  Future<ActionParseResponse> parse(String address) {
    return dio.get('/action/parse?address=$address').then((value) {
      return ActionParseResponse(Action.from(value.data));
    });
  }

  @override
  Future<Withdraw> getWithdrawInfo(Withdraw action) {
    return dio.post('/action/info', data: {'action': action}).then(
        (value) => Withdraw.fromJson(value.data));
  }

  @override
  Future<Payment> getPaymentInfo(Payment action) {
    return dio.post('/action/info',
        data: {'action': action}).then((value) => Payment.fromJson(value.data));
  }

  @override
  Future<Transaction> pay(Payment p) {
    return dio.post('/pay',
        data: {'action': p}).then((value) => Transaction.fromJson(value.data));
  }

  @override
  Future<Withdraw> withdraw(Withdraw w) {
    return dio.post('/withdraw',
        data: {'action': w}).then((value) => Withdraw.fromJson(value.data));
  }
}

abstract class ActionRepository {
  Dio dio;
  Future<ActionParseResponse> parse(String address);
  Future<Payment> getPaymentInfo(Payment action);
  Future<Withdraw> getWithdrawInfo(Withdraw action);
  Future<Transaction> pay(Payment p);
  Future<Withdraw> withdraw(Withdraw w);
  ActionRepository(this.dio);
}

class ActionParseResponse {
  Payment? payment;
  Withdraw? withdraw;
  ActionParseResponse(dynamic e) {
    if (e is Payment) {
      payment = e;
    } else if (e is Withdraw) {
      withdraw = e;
    }
  }
}
