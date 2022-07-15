import 'package:sudonym/constants.dart';
import 'package:flutter/material.dart';

//This is the base of all notifications

class BaseNotification extends StatelessWidget {
  final String text;
  final Color textColor;

  const BaseNotification(
      {Key? key, required this.text, required this.textColor})
      : super(key: key);

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
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 17,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
