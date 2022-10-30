import 'package:dartz/dartz.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/logic/bloc/action.cubit.dart';

class WithdrawManager extends ActionManager<Withdraw> {
  static canChangeAmount(Withdraw w) {
    if (w.minAmount != w.maxAmount || w.amount == 0 || w.amount == null) {
      return true;
    }
    return false;
  }

  @override
  info(Withdraw action) {
    return Task(() => actionRepository.getWithdrawInfo(action)).attempt().run();
  }

  @override
  execute(Withdraw action) {
    return Task(() => actionRepository.withdraw(action)).attempt().run();
  }
}
