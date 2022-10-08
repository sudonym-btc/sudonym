import 'package:flutter/material.dart';
import 'package:sudonym/presentation/index.dart';

class SettingButtons extends StatelessWidget {
  final icon1;
  final onPressed;
  const SettingButtons({
    Key? key,
    required this.icon1,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      elevation: 2.0,
      fillColor: primary,
      child: icon1,
      padding: const EdgeInsets.all(15.0),
      shape: const CircleBorder(),
      onPressed: onPressed,
    );
  }
}


// credid_card
//edit
// add

