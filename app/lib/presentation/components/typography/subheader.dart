import 'package:flutter/material.dart';

@immutable
class Subheader extends StatelessWidget {
  final String? text;

  const Subheader(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(text!, style: Theme.of(context).textTheme.displayMedium);
  }
}
