import 'package:flutter/material.dart';

@immutable
class Button extends StatelessWidget {
  final String? text;
  final Widget? icon;
  final void Function()? onPressed;
  final Color? backgroundColor;
  final ElevatedButtonThemeData? style;

  const Button(
      {Key? key,
      this.backgroundColor,
      this.text,
      this.icon,
      this.onPressed,
      this.style})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (icon != null) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon!,
        label: Text(text ?? ''),
      );
    }
    return ElevatedButton(
      onPressed: onPressed,
      style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
          backgroundColor: backgroundColor != null
              ? MaterialStatePropertyAll(backgroundColor)
              : Theme.of(context).elevatedButtonTheme.style!.backgroundColor),
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
        onPressed: onPressed,
        text: text,
        icon: icon,
      );
  factory Button.round(
          {Color foregroundColor = Colors.white,
          Color backgroudColor = Colors.transparent,
          required String text,
          Function()? onPressed,
          Widget? icon}) =>
      Button(
        // style: raisedButtonStyle.copyWith(
        //     textStyle: MaterialStatePropertyAll(
        //         TextStyle(fontWeight: FontWeight.bold)),
        //     minimumSize: MaterialStateProperty.resolveWith(
        //         (states) => const Size(48, 48)),
        //     maximumSize: MaterialStateProperty.resolveWith(
        //         (states) => const Size(48, 48))),
        onPressed: onPressed,
        text: text,
        icon: icon,
      );
}
