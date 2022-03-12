import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sudonym/presentation/widgets/send/qr.dart';

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
              body: Container(
                  child: Column(
                children: [
                  // Expanded(flex: 5, child: QRView()),
                  TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Lightning address/snippet',
                    ),
                  ),
                  ElevatedButton.icon(
                    label: Text('Send'),
                    icon: FaIcon(FontAwesomeIcons.paperPlane, size: 14),
                    onPressed: () {
                      Navigator.pushNamed(context, '/send');
                    },
                  )
                ],
              ))),
        ));
  }
}
