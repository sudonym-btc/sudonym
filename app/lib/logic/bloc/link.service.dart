import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/address-parse-response-to-payment.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/data/repository/pay.repository.dart';
import 'package:sudonym/presentation/pages/send/amount.dart';

@lazySingleton
@injectable
class LinkService {
  final PayRepository _payRepository;

  LinkService(this._payRepository);

  trigger(String link, BuildContext context, [int? potId]) async {
    AddressParseResponse response = await _payRepository.parse(link);

    Payment pay = AddressParseResponseToPayment(response);
    pay.set("potId", potId);
    if (response.get("success")) {
      if (pay.get("amount") == null) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => AmountPage(pay)));
      } else {
        Navigator.pushNamed(context, '/confirmSend', arguments: pay);
      }
    }
    return;
  }
}
