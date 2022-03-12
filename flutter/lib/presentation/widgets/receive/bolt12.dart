import 'package:clipboard/clipboard.dart';
import 'package:clipboard_listener/clipboard_listener.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sudonym/presentation/widgets/currency/currency_input.dart';

import '../../../constants.dart';

class ReceiveBolt12 extends StatelessWidget {
  const ReceiveBolt12({Key? key}) : super(key: key);

  get Clipboard => null;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        QrImage(
          data: "1234567890",
          version: QrVersions.auto,
          // embeddedImage: AssetImage('assets/images/my_embedded_image.png'),
          // embeddedImageStyle: QrEmbeddedImageStyle(
          //   size: Size(80, 80),
          // ),
        ),
        SizedBox(height: padding),
        Padding(
          padding: EdgeInsets.all(padding),
          child: CurrencyInput(),
        ),
        Expanded(child: Container()),
        Padding(
            padding: EdgeInsets.all(padding),
            child: ElevatedButton(
                onPressed: () {
                  ClipboardListener.addListener(() async {
                    "粘贴板发生改变:${(await Clipboard.getData(Clipboard.kTextPlain))!.text}";
                  });
                  FlutterClipboard.copy("example").then((value) {
                    final snackBar = SnackBar(
                      content: Text('Copied to Clipboard'),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () {},
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  });
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(
                      40), // fromHeight use double.infinity as width and 40 is the height
                ),
                child: Text("Copy"))),
        Padding(
            padding: EdgeInsets.all(padding),
            child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(
                      40), // fromHeight use double.infinity as width and 40 is the height
                ),
                child: Text("Share")))
      ],
    ));
  }
}
