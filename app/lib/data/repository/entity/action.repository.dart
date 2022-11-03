import 'dart:async';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym.models/index.dart';

@LazySingleton(as: ActionRepository, env: Env.allButMock)
class ActionRepositoryImpl extends ActionRepository {
  ActionRepositoryImpl(Dio dio) : super(dio);

  @override
  Future<ActionParseResponse> parse(String address) {
    return dio.get('/action/parse?address=$address').then((value) {
      return ActionParseResponse.fromJson(value.data) as ActionParseResponse;
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
    return dio.post('/action',
        data: {'action': p}).then((value) => Transaction.fromJson(value.data));
  }

  @override
  Future<Receiver> withdraw(Withdraw w) {
    return dio.post('/action',
        data: {'action': w}).then((value) => Receiver.fromJson(value.data));
  }
}

abstract class ActionRepository {
  Dio dio;
  Future<ActionParseResponse> parse(String address);
  Future<Payment> getPaymentInfo(Payment action);
  Future<Withdraw> getWithdrawInfo(Withdraw action);
  Future<Transaction> pay(Payment p);
  Future<Receiver> withdraw(Withdraw w);
  ActionRepository(this.dio);
}

// class ActionParseResponse {
//   Payment? payment;
//   Withdraw? withdraw;
//   ActionParseResponse(dynamic e) {
//     if (e.payment != null) {
//       payment = Payment.fromJson(e);
//     } else if (e.withdraw != null) {
//       withdraw = Withdraw.fromJson(e);
//     }
//   }
// }
