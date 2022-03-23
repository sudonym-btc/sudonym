import 'package:flutter/material.dart';

import '../constants.dart';

ThemeData themeData = ThemeData(
  tabBarTheme: TabBarTheme(labelColor: textColor),
  appBarTheme: const AppBarTheme(
      foregroundColor: textColor,
      toolbarTextStyle: TextStyle(color: textColor),
      titleTextStyle: TextStyle(color: textColor),
      iconTheme: IconThemeData(color: textColor),
      actionsIconTheme: IconThemeData(color: textColor),
      backgroundColor: Colors.white,
      elevation: 0),
  scaffoldBackgroundColor: Colors.white,
  elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
          foregroundColor: MaterialStateProperty.resolveWith<Color?>((s) {
            if (s.contains(MaterialState.disabled))
              return Colors.black; // Disabled button color
            return Colors.white; // Enabled button color
          }),
          backgroundColor: MaterialStateProperty.resolveWith<Color?>((s) {
            if (s.contains(MaterialState.disabled))
              return primary.shade100; // Disabled button color
            return primary; // Enabled button color
          }),
          shadowColor: MaterialStateProperty.all<Color>(Colors.transparent))),
  fontFamily: 'Satoshi',
  backgroundColor: Colors.white,
);
