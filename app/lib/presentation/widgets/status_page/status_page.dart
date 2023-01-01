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
  final Color? color;

  const StatusPage(
      {Key? key,
      this.pageTitle = '',
      this.title,
      this.subtitle,
      this.subtitleText,
      this.icon,
      this.content,
      this.actions,
      this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData currTheme = Theme.of(context).copyWith();
    ThemeData newTheme = (color != null ? darkTheme : Theme.of(context))
        .copyWith(
            backgroundColor: color ?? currTheme.backgroundColor,
            appBarTheme: color != null
                ? darkTheme.appBarTheme.copyWith(backgroundColor: color)
                : currTheme.appBarTheme,
            elevatedButtonTheme: ElevatedButtonThemeData(
                style: currTheme.elevatedButtonTheme.style!.copyWith(
                    backgroundColor:
                        MaterialStatePropertyAll(Colors.white.withAlpha(50)))),
            scaffoldBackgroundColor: color ?? currTheme.scaffoldBackgroundColor,
            progressIndicatorTheme:
                ProgressIndicatorThemeData(color: Colors.white));

    List<Widget> children = [];
    if (title != null) {
      children.add(FittedBox(
          alignment: Alignment.centerLeft,
          fit: BoxFit.scaleDown,
          child: Header(title)));
    }
    if (subtitle != null || subtitleText != null) {
      children.add(subtitle ?? Subtitle(subtitleText));
    }
    if (title != null || subtitle != null || subtitleText != null) {
      children.add(const VertDivider(2));
    }
    if (content == null && icon == null) {
      children.add(Expanded(child: Container()));
    } else {
      if (content != null) {
        children.add(Expanded(child: content!));
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
      children.addAll([actions!]);
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
                body: CustomPadding(
                    multiplier: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: children,
                    ))),
          )),
    );
  }
}
