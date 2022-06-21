import 'package:flutter/material.dart';

@immutable
class TextInput extends TextFormField {
  TextInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
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
    );
  }
}
