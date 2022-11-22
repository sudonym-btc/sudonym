import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sudonym/presentation/index.dart';

class StatusPage extends StatelessWidget {
  final String pageTitle;
  final String? title;
  final Widget? subtitle;
  final String? subtitleText;
  final IconData? icon;
  final Widget? content;
  final Widget? actions;
  final Color color;

  const StatusPage(
      {Key? key,
      this.pageTitle = '',
      this.title,
      this.subtitle,
      this.subtitleText,
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
        appBarTheme: currTheme.appBarTheme.copyWith(
            foregroundColor: Colors.white,
            toolbarTextStyle: const TextStyle(color: Colors.white),
            titleTextStyle: const TextStyle(color: Colors.white),
            iconTheme: const IconThemeData(color: Colors.white),
            // actionsIconTheme: const IconThemeData(color: textColor),
            backgroundColor: color,
            elevation: 0),
        scaffoldBackgroundColor: color,
        textTheme: currTheme.textTheme.apply(
          bodyColor: Colors.white.withAlpha(240),
          displayColor: Colors.white.withAlpha(150),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(Colors.black),
          backgroundColor: MaterialStateProperty.all(Colors.white),
        ))
        // foregroundColor: MaterialStateProperty.all(textColor))),
        );

    List<Widget> children = [];
    if (title != null) children.add(Header(title));
    if (subtitle != null || subtitleText != null) {
      children.add(subtitle ?? Subtitle(subtitleText));
    }
    if (title != null || subtitle != null || subtitleText != null) {
      children.add(const SizedBox(height: padding * 2));
    }
    if (content == null && icon == null) {
      children.add(Expanded(child: Container()));
    } else {
      if (content != null) {
        children.add(content!);
      }
      if (icon != null) {
        children.add(Expanded(
            child: Center(
          child: FaIcon(
            icon,
            color: Colors.white.withAlpha(100),
            size: 60,
          ),
        )));
      }
    }

    if (actions != null) {
      children.addAll([Expanded(child: Container()), actions!]);
    }

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
