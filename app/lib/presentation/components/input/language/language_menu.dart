//Dropdown Language menu

import 'package:flutter/material.dart';
import 'package:sudonym/constants.dart';

class LanguageMenu extends StatefulWidget {
  const LanguageMenu({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _LanguageMenuState createState() => _LanguageMenuState();
}

class _LanguageMenuState extends State<LanguageMenu> {
  String valueChoose = "English";
  List listItem = ['English', 'German', 'Spanish', 'Portuguese', 'French'];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.only(left: 16, right: 16),
          decoration: BoxDecoration(
              border: Border.all(color: greyTint, width: 1),
              borderRadius: BorderRadius.circular(10)),
          child: DropdownButton(
            hint: const Text('Choose your language'),
            dropdownColor: Colors.white,
            icon: const Icon(Icons.language_rounded),
            iconSize: 36,
            isExpanded: true,
            underline: SizedBox(),
            style: const TextStyle(color: textColor, fontSize: 17),
            value: valueChoose,
            onChanged: (newValue) {
              setState(
                () {
                  valueChoose = newValue as String;
                },
              );
            },
            items: listItem.map(
              (valueItem) {
                return DropdownMenuItem(
                  value: valueItem,
                  child: (Text(valueItem)),
                );
              },
            ).toList(),
          ),
        ),
      ),
    );
  }
}
