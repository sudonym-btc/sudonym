import 'package:flutter/material.dart';

const padding = 12.0;
const buttonRadius = 44 / 2;

//colors
const textColor = Colors.black;
const textColorLight = Colors.black;
const primary = Colors.indigo;
const successColor = Color.fromARGB(194, 20, 116, 46);
const errorColor = Color.fromARGB(194, 206, 0, 0);
const greyTint = Color.fromARGB(100, 94, 94, 94);

const iconSize = 12.0;
const animationDuration = Duration(milliseconds: 600);

final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
    minimumSize: const Size(120, 44),
    elevation: 0,
    padding:
        const EdgeInsets.symmetric(horizontal: padding * 2, vertical: padding),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(buttonRadius)),
    ),
    shadowColor: Colors.transparent);

BoxDecoration buttonDecoration(BuildContext context, bool enabled) {
  List<MaterialState> states = [];
  if (!enabled) states.add(MaterialState.disabled);
  return BoxDecoration(
      color: Theme.of(context)
          .elevatedButtonTheme
          .style!
          .backgroundColor!
          .resolve(Set.of(states)),
      shape: BoxShape.rectangle,
      borderRadius: const BorderRadius.all(
          Radius.elliptical(buttonRadius, buttonRadius)));
}
