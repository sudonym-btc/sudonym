import 'package:flutter/material.dart';

ThemeData getTheme({bool light = true}) {
  ThemeData theme = ThemeData();
  if (!light) theme = ThemeData.dark();

  Color textColor = light ? Colors.black : Colors.white;
  Color backgroundColor = light ? Colors.white : Colors.black;

  return theme.copyWith(
      tabBarTheme: TabBarTheme(
        labelColor: textColor,
        indicator: BoxDecoration(
            color: backgroundColor,
            border: Border(bottom: BorderSide(color: primary, width: 2))),
      ),
      appBarTheme: AppBarTheme(
          foregroundColor: textColor,
          toolbarTextStyle: TextStyle(color: textColor),
          titleTextStyle: TextStyle(
              color: textColor, fontSize: 30, fontWeight: FontWeight.w900),
          iconTheme: IconThemeData(color: textColor),
          actionsIconTheme: IconThemeData(color: textColor),
          backgroundColor: backgroundColor,
          toolbarHeight: 60,
          elevation: 0),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: primary),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
              foregroundColor: MaterialStateProperty.resolveWith<Color?>((s) {
                if (s.contains(MaterialState.disabled)) {
                  return Colors.black;
                } // Disabled button color
                return Colors.white; // Enabled button color
              }),
              backgroundColor: MaterialStateProperty.resolveWith<Color?>((s) {
                if (s.contains(MaterialState.disabled)) {
                  return primary.shade100;
                } // Disabled button color
                return primary; // Enabled button color
              }),
              shadowColor:
                  MaterialStateProperty.all<Color>(Colors.transparent))),
      // fontFamily: 'Satoshi',
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primary,
      inputDecorationTheme: const InputDecorationTheme(
          floatingLabelStyle: TextStyle(color: primary),
          focusedBorder: UnderlineInputBorder(
            borderSide:
                BorderSide(style: BorderStyle.solid, width: 2, color: primary),
          )),
      textTheme: TextTheme(
          displayMedium: TextStyle(
              color: textColor, fontSize: 20, fontWeight: FontWeight.w900),
          displayLarge: TextStyle(
              color: textColor, fontSize: 30, fontWeight: FontWeight.w900)));
}

const padding = 12.0;
const buttonRadius = 44 / 2;

//colors
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
