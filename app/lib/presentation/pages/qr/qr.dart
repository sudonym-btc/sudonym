import 'package:flutter/material.dart' hide ButtonBar;
import 'package:sudonym/presentation/index.dart';

class QRPage extends StatefulWidget {
  final int? potId;
  const QRPage(this.potId, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _QRPageState();
  }
}

class _QRPageState extends State<QRPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).colorScheme.background,
        child: SafeArea(
            child: Scaffold(appBar: AppBar(), body: QRView(widget.potId))));
  }
}
