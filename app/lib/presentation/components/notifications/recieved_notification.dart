import 'package:flutter/material.dart';
import 'package:sudonym/constants.dart';
import 'package:sudonym/presentation/components/notifications/base_notification.dart';

//Recieved Notification

class RecievedNotification extends StatelessWidget {
  String text;

  RecievedNotification({
    required this.text,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseNotification(text: text, textColor: successColor);
  }
}
