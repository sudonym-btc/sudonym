import 'package:flutter/widgets.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/logic/index.dart';

class QRView extends StatelessWidget {
  final int? potId;

  const QRView(this.potId, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MobileScanner(
        fit: BoxFit.fill,
        allowDuplicates: false,
        onDetect: (barcode, args) {
          final String? code = barcode.rawValue;
          getIt<ActionTriggerService>().trigger(code!, context, potId);
        });
  }
}
