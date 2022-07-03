import 'package:dart_lnurl/dart_lnurl.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/data/repository/pay.repository.dart';
import 'package:sudonym/presentation/pages/send/amount.dart';

@lazySingleton
@injectable
class LinkService {
  final PayRepository _payRepository;

  LinkService(this._payRepository);

  trigger(String link, BuildContext context) async {
    AddressParseResponse response = await _payRepository.parse(link);

    print(response);
    Payment pay = response.toPayment();

    if (response.success) {
      if (pay.amount == null) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => AmountPage(pay)));
      } else {
        Navigator.pushNamed(context, '/confirmSend', arguments: pay);
      }
    }
    return;
  }
}
