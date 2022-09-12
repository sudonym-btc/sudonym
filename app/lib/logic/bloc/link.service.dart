import 'package:flutter/material.dart' hide Action;
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/config/logger.dart';
import 'package:sudonym/data/repository/action.repository.dart';
import 'package:sudonym/presentation/pages/send/amount.dart';

@lazySingleton
@injectable
class LinkService with ActionLogger {
  final ActionRepository _actionRepository;

  LinkService(this._actionRepository);

  trigger(String link, BuildContext context, [int? potId]) async {
    ActionParseResponse response = await _actionRepository.parse(link);

    if (response.payment != null) {
      handlePayment(response.payment!, context, potId);
    }

    return;
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
  }

  canChangeAmount(Payment p) {
    if (p.minAmount != p.maxAmount || p.amount == 0 || p.amount == null) {
      return true;
    }
    return false;
  }
}
