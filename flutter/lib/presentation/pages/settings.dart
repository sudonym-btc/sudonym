import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sudonym/constants.dart';

final _formKey = GlobalKey<FormState>();

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
                  child: Form(
                    key: _formKey,
                    child: Column(children: [
                      // Text(
                      //   "Lightning Address",
                      //   style: Theme.of(context).textTheme.headline4,
                      // ),
                      SizedBox(
                        height: padding,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                            hintText: 'e.g. satoshi',
                            labelText: 'Lightning address',
                            suffixText: '@sudonym.app'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                    ]),
                  ),
                ))));
  }
}
