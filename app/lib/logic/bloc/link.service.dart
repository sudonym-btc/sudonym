import 'package:dart_lnurl/dart_lnurl.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/presentation/pages/send/amount.dart';

@lazySingleton
@injectable
class LinkService {
  trigger(String link, BuildContext context) {
    decode(link);
    String decoded = 'lnurl';

    if (['lnurl', 'ln', 'onchain'].contains(decoded)) {
      if (false) {
        Navigator.pushNamed(context, '/confirmSend',
            arguments: {"address": link});
      } else {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    AmountPage(Payment(link, null, null, null))));
      }
    }
  }

  decode(String str) async {
    if (str.startsWith('lnurl')) {
      LNURLParseResult parsed = await getParams(str);
      print(parsed.payParams);
    } else if (str.startsWith('ln')) {}
  }
}
