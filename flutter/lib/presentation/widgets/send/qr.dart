import 'package:flutter/widgets.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      // width: 200,
      height: 300,
        child: MobileScanner(
            allowDuplicates: false,
            onDetect: (barcode, args) {
              final String? code = barcode.rawValue;
              debugPrint('Barcode found! $code');
            }));
  }
}
