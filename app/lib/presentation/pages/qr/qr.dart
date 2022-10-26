import 'package:flutter/material.dart' hide ButtonBar;
import 'package:sudonym.models/index.dart';
import 'package:sudonym/presentation/index.dart';

class QRPage extends StatefulWidget {
  final Pot? pot;
  const QRPage(this.pot, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _QRPageState();
  }
}

class _QRPageState extends State<QRPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).backgroundColor,
        child: Stack(children: [
          QRView(widget.pot),
          SafeArea(
              child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
            ),
            backgroundColor: Colors.transparent,
          ))
        ]));
  }
}
