import 'package:flutter/material.dart';
import 'package:sudonym/constants.dart';

//Paste Notification

class PasteNotification extends StatelessWidget {
  const PasteNotification({Key? key, OnPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 400,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: greyTint,
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: greyTint,
              ),
              child: const Text(
                'Tap here to paste address!',
                style: TextStyle(
                  color: textColor,
                  fontSize: 17,
                ),
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
