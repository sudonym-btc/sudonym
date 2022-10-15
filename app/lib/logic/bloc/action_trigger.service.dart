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

  trigger(String link, BuildContext context, [int? potId]) async {
    ActionParseResponse response = await _actionRepository.parse(link);
    loggy.i(response.payment);
    loggy.i(response.withdraw);
    if (response.payment != null) {
      handlePayment(response.payment!, context, potId);
    }
    if (response.withdraw != null) {
      handleWithdraw(response.withdraw!, context, potId);
    }
  }

  handlePayment(Payment p, BuildContext c, [int? potId]) {
    p.potId = potId;

    if (p.remoteResponse.success) {
      if (canChangeAmount(p)) {
        return Navigator.push(
            c, MaterialPageRoute(builder: (context) => AmountPage(p)));
      }
      return Navigator.pushNamed(c, '/confirmSend', arguments: p);
    }
    handleError(c, p.remoteResponse);
  }

  handleWithdraw(Withdraw w, BuildContext c, [int? potId]) {
    print("Ya mug");
    w.potId = potId;

    if (w.remoteResponse.success) {
      if (canChangeAmountWithdraw(w)) {
        return Navigator.push(
            c, MaterialPageRoute(builder: (context) => AmountPage(w)));
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
                content: Text("${a.data['statusCode']}: ${a.data['message']}"),
                color: Theme.of(context).errorColor)));
  }
}
