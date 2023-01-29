import 'package:dartz/dartz.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym.models/index.dart';

class PayManager extends ActionManager<Payment> {
  static canChangeAmount(Payment p) {
    if (p.minAmount != p.maxAmount || p.amount == 0 || p.amount == null) {
      return true;
    }
    return false;
  }

  @override
  Future<Either<Object, Payment>> info(Payment action) {
    return Task(() => actionRepository.getPaymentInfo(action).then((value) {
          return value;
        })).attempt().run();
  }

  @override
  Future<Either<Object, Transaction>> execute(Payment action) {
    return Task(() => actionRepository.pay(action)).attempt().run();
  }
}
