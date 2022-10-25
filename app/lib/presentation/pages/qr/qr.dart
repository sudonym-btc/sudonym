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
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).backgroundColor,
        child: Stack(children: [
          QRView(widget.potId),
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
