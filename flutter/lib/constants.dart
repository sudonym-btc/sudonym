import 'package:flutter/material.dart';

const padding = 12.0;
const textColor = Colors.black;
const textColorLight = Colors.black;
const iconSize = 12.0;

final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
  minimumSize: Size(120, 44),
  padding: EdgeInsets.symmetric(horizontal: 16),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(5)),
  ),
);

final BoxDecoration buttonDecoration = BoxDecoration(
    color: Colors.lightBlue,
    shape: BoxShape.rectangle,
    borderRadius: BorderRadius.all(Radius.elliptical(6, 6)));
