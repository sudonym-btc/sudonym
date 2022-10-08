import 'package:flutter/material.dart';

@immutable
class Emphasized extends StatelessWidget {
  final String? text;

  const Emphasized(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(text!, style: Theme.of(context).textTheme.headline4);
  }
}
