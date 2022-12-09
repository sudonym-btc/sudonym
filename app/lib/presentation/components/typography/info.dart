import 'package:flutter/material.dart';

@immutable
class Info extends StatelessWidget {
  final String? text;
  final TextStyle? style;
  const Info(this.text, {Key? key, this.style}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(text ?? '',
        style: Theme.of(context)
            .textTheme
            .bodySmall!
            .merge(style ?? const TextStyle()));
  }
}
