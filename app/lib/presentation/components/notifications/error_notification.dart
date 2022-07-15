import 'package:flutter/material.dart';
import 'package:sudonym/constants.dart';
import 'package:sudonym/presentation/components/notifications/base_notification.dart';

//Error notification

class ErrorNotification extends StatelessWidget {
  String text;

  ErrorNotification({
    required this.text,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseNotification(text: text, textColor: errorColor);
  }
}
