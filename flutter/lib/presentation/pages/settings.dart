import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sudonym/constants.dart';

import '../widgets/pot/pot.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).colorScheme.background,
        child: SafeArea(
            child: Scaffold(
          appBar: AppBar(title: new Text("Settings")),
          body: Container(
            padding: EdgeInsets.all(padding),
            child: Column(children: [
              Text(
                "Lightning Address",
                style: Theme.of(context).textTheme.headline4,
              ),
              SizedBox(
                height: padding,
              ),
            ]),
          ),
        )));
  }
}
