import 'package:flutter/material.dart';
import 'package:sudonym/constants.dart';
import 'package:sudonym/presentation/index.dart';

//Sent Notification

class SentNotification extends StatelessWidget {
  String text;

  SentNotification({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseNotification(text: text, textColor: successColor);
  }
}
