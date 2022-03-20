import 'package:flutter/material.dart';

const padding = 12.0;
const buttonRadius = 44 / 2;
const textColor = Colors.black;
const textColorLight = Colors.black;
const primary = Colors.blue;
const iconSize = 12.0;

final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
  minimumSize: const Size(120, 44),
  padding: const EdgeInsets.symmetric(horizontal: padding * 2, vertical: padding),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(buttonRadius)),
  ),
);

BoxDecoration buttonDecoration(BuildContext context, bool enabled) {
  List<MaterialState> states = [];
  if(!enabled) states.add(MaterialState.disabled);
  return BoxDecoration(
    color: Theme.of(context).elevatedButtonTheme.style!.backgroundColor!.resolve(Set.of(states)),
    shape: BoxShape.rectangle,
    borderRadius: const BorderRadius.all(Radius.elliptical(buttonRadius, buttonRadius)));
}
