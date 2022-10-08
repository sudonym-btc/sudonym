import 'package:flutter/material.dart';

@immutable
class Subtitle extends StatelessWidget {
  final String? text;

  const Subtitle(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(text!,
        textAlign: TextAlign.start,
        style: Theme.of(context).textTheme.labelLarge);
  }
}
