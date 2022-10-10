import 'package:flutter/material.dart';

@immutable
class Info extends StatelessWidget {
  final String? text;

  const Info(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(text ?? '', style: Theme.of(context).textTheme.bodySmall);
  }
}
