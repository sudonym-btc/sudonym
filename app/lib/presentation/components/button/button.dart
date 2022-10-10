import 'package:flutter/material.dart';
import 'package:sudonym/presentation/index.dart';

@immutable
class Button extends StatelessWidget {
  final String? text;
  final Widget? icon;
  final void Function()? onPressed;
  final ButtonStyle? style;

  const Button({Key? key, this.text, this.icon, this.onPressed, this.style})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (icon != null) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon!,
        label: Text(text ?? ''),
        style: style ?? raisedButtonStyle,
      );
    }
    return ElevatedButton(
      style: style ?? raisedButtonStyle,
      onPressed: onPressed,
      child: Text(text!),
    );
  }

  factory Button.flat(
          {Color foregroundColor = Colors.white,
          Color backgroudColor = Colors.transparent,
          required String text,
          Function()? onPressed,
          Widget? icon}) =>
      Button(
        style: raisedButtonStyle.copyWith(
            foregroundColor:
                MaterialStateColor.resolveWith((states) => foregroundColor),
            backgroundColor:
                MaterialStateColor.resolveWith((states) => backgroudColor)),
        onPressed: onPressed,
        text: text,
        icon: icon,
      );
}
