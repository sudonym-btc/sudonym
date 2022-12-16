import 'package:flutter/material.dart';

@immutable
class ErrorText extends StatelessWidget {
  final String? text;
  const ErrorText(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(text ?? '',
        style: Theme.of(context)
            .textTheme
            .bodySmall!
            .merge(TextStyle(color: Theme.of(context).errorColor)));
  }
}
