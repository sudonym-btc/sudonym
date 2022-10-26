import 'package:flutter/material.dart' hide Action;
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/config/logger.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/presentation/index.dart';

@lazySingleton
@injectable
class ActionTriggerService with ActionLogger {
  final ActionRepository _actionRepository;

  ActionTriggerService(this._actionRepository);

  trigger(String link, BuildContext context, [Pot? pot]) async {
    ActionParseResponse response = await _actionRepository.parse(link);
    if (response.payment != null) {
      loggy.i(response.payment.toJson());
      handlePayment(response.payment!, context, pot);
    }
    if (response.withdraw != null) {
      loggy.i(response.withdraw.toJson());
      handleWithdraw(response.withdraw!, context, pot);
    }
  }

  handlePayment(Payment p, BuildContext c, [Pot? pot]) {
    p.potId = pot?.id;

    if (p.remoteResponse.success) {
      if (canChangeAmount(p)) {
        return Navigator.push(
            c,
            MaterialPageRoute(
                builder: (context) => AmountPage(action: p, pot: pot)));
      }
      return Navigator.pushNamed(c, '/confirmSend', arguments: p);
    }
    handleError(c, p.remoteResponse);
  }

  handleWithdraw(Withdraw w, BuildContext c, [Pot? pot]) {
    w.potId = pot?.id;

    if (w.remoteResponse.success) {
      if (canChangeAmountWithdraw(w)) {
        return Navigator.push(
            c,
            MaterialPageRoute(
                builder: (context) => AmountPage(action: w, pot: pot)));
      }
      return Navigator.pushNamed(c, '/confirmWithdraw', arguments: w);
    }
    handleError(c, w.remoteResponse);
  }

  canChangeAmountWithdraw(Withdraw p) {
    if (p.minAmount != p.maxAmount || p.amount == 0 || p.amount == null) {
      return true;
    }
    return false;
  }

  canChangeAmount(Payment p) {
    if (p.minAmount != p.maxAmount || p.amount == 0 || p.amount == null) {
      return true;
    }
    return false;
  }

  handleError(BuildContext c, ActionRemoteResponse a) {
    return Navigator.push(
        c,
        MaterialPageRoute(
            builder: (context) => StatusPage(
                title: 'Error',
                subtitle: 'Could not get an OK response from remote server',
                content: Text("${a.data['status']}: ${a.message.toString()}"),
                color: Theme.of(context).errorColor)));
  }
}
