import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sudonym/constants.dart';
import 'package:sudonym/logic/bloc/auth.cubit.dart';

import '../../../injection.dart';
import '../../pages/home_page.dart';
import '../../pages/signin.dart';

class SendReceive extends StatelessWidget {
  const SendReceive({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
      // onPrimary: Colors.black87,
      // primary: Colors.grey[300],
      minimumSize: Size(120, 44),
      padding: EdgeInsets.symmetric(horizontal: 16),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
    );
    return Container(
        padding: const EdgeInsets.all(padding),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, //Center Column contents vertically,
          crossAxisAlignment:
              CrossAxisAlignment.center, //Center Column contents horizontally,
          children: [
            Container(
              child: Image(
                width: 200,
                image: NetworkImage(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0b/QR_code_Wikimedia_Commons_%28URL%29.png/600px-QR_code_Wikimedia_Commons_%28URL%29.png'),
              ),
            ),
            SizedBox(height: padding),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center, //Center Row contents horizontally,
              crossAxisAlignment: CrossAxisAlignment
                  .center, //Center Column contents horizontally,
              children: [
                ElevatedButton.icon(
                  label: Text('Receive'),
                  style: raisedButtonStyle,
                  icon: FaIcon(FontAwesomeIcons.inbox, size: 14),
                  onPressed: () {
                    Navigator.pushNamed(context, '/receive');
                  },
                ),
                SizedBox(
                  width: 10,
                ),
                ElevatedButton.icon(
                  label: Text('Send'),
                  style: raisedButtonStyle,
                  icon: FaIcon(FontAwesomeIcons.paperPlane, size: 14),
                  onPressed: () {
                    Navigator.pushNamed(context, '/send');
                  },
                )
              ],
            )
          ],
        ));
  }
}
