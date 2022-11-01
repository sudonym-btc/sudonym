import 'package:flutter/widgets.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/logic/index.dart';

class QRView extends StatelessWidget {
  final Pot? pot;

  const QRView(this.pot, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MobileScanner(
        fit: BoxFit.fill,
        allowDuplicates: false,
        onDetect: (barcode, args) {
          final String? code = barcode.rawValue;
          getIt<ActionTriggerService>()
              .trigger(ActionStream(context: context, link: code!, pot: pot));
        });
  }
}
