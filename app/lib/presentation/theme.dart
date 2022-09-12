import 'package:flutter/material.dart';

import '../constants.dart';

ThemeData themeData = ThemeData(
    tabBarTheme: const TabBarTheme(
      labelColor: textColor,
      indicator: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: primary, width: 2))),
    ),
    appBarTheme: const AppBarTheme(
        foregroundColor: textColor,
        toolbarTextStyle: TextStyle(color: textColor),
        titleTextStyle: TextStyle(
            color: textColor, fontSize: 30, fontWeight: FontWeight.w900),
        iconTheme: IconThemeData(color: textColor),
        actionsIconTheme: IconThemeData(color: textColor),
        backgroundColor: Colors.white,
        toolbarHeight: 60,
        elevation: 0),
    scaffoldBackgroundColor: Colors.white,
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
            shadowColor: MaterialStateProperty.all<Color>(Colors.transparent))),
    // fontFamily: 'Satoshi',
    backgroundColor: Colors.white,
    primaryColor: primary,
    inputDecorationTheme: const InputDecorationTheme(
        floatingLabelStyle: TextStyle(color: primary),
        focusedBorder: UnderlineInputBorder(
          borderSide:
              BorderSide(style: BorderStyle.solid, width: 2, color: primary),
        )),
    textTheme: const TextTheme(
        subtitle1: TextStyle(),
        headlineLarge: TextStyle(
            color: Colors.black, fontSize: 30, fontWeight: FontWeight.w900)));
