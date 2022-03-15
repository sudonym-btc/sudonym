import 'package:flutter/material.dart' hide ButtonBar;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sudonym/presentation/widgets/input/button/button_bar.dart';
import 'package:sudonym/presentation/widgets/send/qr.dart';

import '../../constants.dart';

final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

class SendPage extends StatelessWidget {
  const SendPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).colorScheme.background,
        child: SafeArea(
          child: Scaffold(
              appBar: AppBar(
                title: const Text('Send'),
              ),
              body: Padding(
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    children: [
                      Expanded(child: QRView()),
                      const SizedBox(height: padding),
                      const TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Lightning address/snippet',
                        ),
                      ),
                      Expanded(child: new Container()),
                      ButtonBar(children: [
                        ElevatedButton.icon(
                          label: Text('Send'),
                          style: raisedButtonStyle,
                          icon: FaIcon(FontAwesomeIcons.paperPlane, size: 14),
                          onPressed: () {
                            Navigator.pushNamed(context, '/confirmSend',arguments: {"address" : "random"});
                          },
                        )
                      ])
                    ],
                  ))),
        ));
  }
}
