import 'package:flutter/material.dart';
import 'package:sudonym/constants.dart';

class UsernameInput extends StatelessWidget {
  const UsernameInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext) {
    return const TextField(
      decoration: InputDecoration(
        fillColor: textColor,
        labelText: 'Enter your username',
        prefixIcon: Icon(
          Icons.person,
        ),
        suffixText: '@sudonym.app,',
        border: OutlineInputBorder(),
      ),
    );
  }
}
