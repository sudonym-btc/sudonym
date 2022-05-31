import 'dart:async';

import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sudonym/constants.dart';

class CurrencyInput extends StatefulWidget {
  final Function? onChanged;

  CurrencyInput({Key? key, this.onChanged}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CurrencyInputState();
  }
}

class _CurrencyInputState extends State<CurrencyInput> {
  StreamController<String> streamController = StreamController();
  final MoneyMaskedTextController _controller = MoneyMaskedTextController(
      initialValue: 0.0, decimalSeparator: '.', thousandSeparator: ',');

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      widget.onChanged!(_controller.numberValue);
    });
  }

  @override
  Widget build(BuildContext context) {

    updateValue(num v) {
      if (_controller.numberValue <= 0 && v <= 0) return;
      _controller.updateValue(_controller.numberValue + v);
    }

    bool negativeEnabled = _controller.numberValue > 0;
    bool positiveEnabled = true;

    List<MaterialState> negativeButtonState = negativeEnabled ? [] : [MaterialState.disabled];
    List<MaterialState> positiveButtonState = positiveEnabled ? [] : [MaterialState.disabled];

    return Row(children: <Widget>[
      Expanded(
        child: TextField(
          decoration: const InputDecoration(
              prefixText: "\$", labelText: "Amount", helperText: "X satoshis"),
          controller: _controller,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          keyboardType: TextInputType.number,
        ),
      ),
      const SizedBox(
        width: padding / 2,
      ),
      Ink(
          decoration: buttonDecoration(context, negativeEnabled),
          child: IconButton(
            onPressed: negativeEnabled ? () => updateValue(-1) : null,
            color: Theme.of(context).elevatedButtonTheme.style!.foregroundColor!.resolve(Set.of(negativeButtonState)),
            icon: const Icon(Icons.remove),
          )),
      const SizedBox(
        width: padding / 2,
      ),
      Ink(
          decoration: buttonDecoration(context, positiveEnabled),
          child: IconButton(
            onPressed: () => updateValue(1),
            color: Theme.of(context).elevatedButtonTheme.style!.foregroundColor!.resolve(Set.of(positiveButtonState)),
            icon: const Icon(Icons.add),
          ))
    ]);
  }
}
