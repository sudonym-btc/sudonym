import 'package:dartz/dartz.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/logic/bloc/action.cubit.dart';

class PayManager extends ActionManager<Payment> {
  static canChangeAmount(Payment p) {
    if (p.minAmount != p.maxAmount || p.amount == 0 || p.amount == null) {
      return true;
    }
    return false;
  }

  @override
  info(Payment action) {
    return Task(() => actionRepository.getPaymentInfo(action)).attempt().run();
  }

  @override
  execute(Payment action) {
    return Task(() => actionRepository.pay(action)).attempt().run();
  }
}
