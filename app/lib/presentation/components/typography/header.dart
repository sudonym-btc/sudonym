import 'package:flutter/material.dart';

@immutable
class Header extends StatelessWidget {
  final String? text;

  const Header(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(text!, style: Theme.of(context).textTheme.headlineLarge);
  }
}
