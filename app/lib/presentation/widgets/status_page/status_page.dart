import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sudonym/presentation/index.dart';

import '../../../constants.dart';

class StatusPage extends StatelessWidget {
  final String pageTitle;
  final String title;
  final String subtitle;
  final IconData? icon;
  final Widget? content;
  final Widget? actions;
  final Color color;

  const StatusPage(
      {Key? key,
      this.pageTitle = '',
      required this.title,
      required this.subtitle,
      this.icon,
      this.content,
      this.actions,
      required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData currTheme = Theme.of(context);
    ThemeData newTheme = currTheme.copyWith(
      backgroundColor: color,
      appBarTheme: themeData.appBarTheme.copyWith(
          foregroundColor: Colors.white,
          toolbarTextStyle: const TextStyle(color: Colors.white),
          titleTextStyle: const TextStyle(color: Colors.white),
          iconTheme: const IconThemeData(color: Colors.white),
          actionsIconTheme: const IconThemeData(color: textColor),
          backgroundColor: color,
          elevation: 0),
      scaffoldBackgroundColor: color,
      textTheme: currTheme.textTheme.apply(
        bodyColor: Colors.white.withAlpha(240),
        displayColor: Colors.white.withAlpha(150),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.white),
              foregroundColor: MaterialStateProperty.all(textColor))),
    );

    var children = [
      Header(title),
      Subtitle(subtitle),
      const SizedBox(height: padding * 2),
      if (content == null && icon == null) Expanded(child: Container())
    ];

    if (icon != null) {
      children = [
        ...children,
        Expanded(
            child: Center(
          child: FaIcon(
            icon,
            color: Colors.white.withAlpha(100),
            size: 60,
          ),
        ))
      ];
    }

    if (content != null) {
      children = [...children, Expanded(child: content!)];
    }

    children = [
      ...children,
      if (actions != null) Expanded(child: Container()),
      if (actions != null) actions!
    ];

    return Theme(
      data: newTheme,
      child: Container(
          color: color,
          child: SafeArea(
            child: Scaffold(
                backgroundColor: color,
                appBar: AppBar(
                  title: Text(pageTitle),
                ),
                body: Padding(
                    padding: const EdgeInsets.all(padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: children,
                    ))),
          )),
    );
  }
}
