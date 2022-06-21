import 'package:flutter/material.dart';
import 'package:sudonym/constants.dart';

@immutable
class Button extends StatelessWidget {
  final String? text;
  final Widget? icon;
  final void Function()? onPressed;

  const Button({Key? key, this.text, this.icon, this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (icon != null) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon!,
        label: Text(text ?? ""),
        style: raisedButtonStyle,
      );
    }
    return ElevatedButton(
      child: Text(text!),
      style: raisedButtonStyle,
      onPressed: onPressed,
    );
  }
}
