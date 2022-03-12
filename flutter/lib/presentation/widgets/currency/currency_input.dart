import 'dart:ffi';

import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sudonym/constants.dart';
import 'package:sudonym/logic/currency/text_formatter.dart';

class CurrencyInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final MoneyMaskedTextController _controller = MoneyMaskedTextController(
        initialValue: 0.0, decimalSeparator: '.', thousandSeparator: ',');

    final buttonDecoration = BoxDecoration(
        color: Colors.lightBlue,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.all(Radius.elliptical(6, 6)));

    updateValue(num v) {
      if (_controller.numberValue <= 0 && v <= 0) return;
      _controller.updateValue(_controller.numberValue + v);
    }

    _controller.addListener(() {
      print(_controller.value.text);
    });

    return Row(children: <Widget>[
      Expanded(
        child: TextField(
          decoration: InputDecoration(
              prefixText: "\$", labelText: "Amount", helperText: "X satoshis"),
          controller: _controller,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          keyboardType: TextInputType.number,
        ),
      ),
      SizedBox(
        width: padding / 2,
      ),
      Ink(
          decoration: buttonDecoration,
          child: IconButton(
            onPressed: () {
              updateValue(-1);
            },
            color: Colors.white,
            icon: Icon(Icons.remove),
          )),
      SizedBox(
        width: padding / 2,
      ),
      Ink(
          decoration: buttonDecoration,
          child: IconButton(
            onPressed: () {
              updateValue(1);
            },
            color: Colors.white,
            icon: Icon(Icons.add),
          ))
    ]);
  }
}
