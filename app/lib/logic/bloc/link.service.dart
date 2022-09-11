import 'package:flutter/material.dart' hide Action;
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/data/repository/action.repository.dart';
import 'package:sudonym/presentation/pages/send/amount.dart';

@lazySingleton
@injectable
class LinkService {
  final ActionRepository _actionRepository;

  LinkService(this._actionRepository);

  trigger(String link, BuildContext context, [int? potId]) async {
    Action response = await _actionRepository.parse(link);
    response.set("potId", potId);

    print(response.toJson());

    if (response.get("remoteResponse").get("success")) {
      if (canChangeAmount(response)) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => AmountPage(response)));
      } else {
        Navigator.pushNamed(context, '/confirmSend', arguments: response);
      }
    }
    return;
  }

  canChangeAmount(Action p) {
    if (p.get("minAmount") != p.get("maxAmount") ||
        p.get("amount") == 0 ||
        p.get("amount") == null) return true;
    return false;
  }
}
