import 'dart:async';

import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sudonym/constants.dart';
import 'package:sudonym/data/repository/currency.repository.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/logic/currency/format-currency.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const List<String> defaultCurrencies = ['USD', 'BTC'];

class CurrencyInput extends StatefulWidget {
  final Function(CurrencyInputOutput)? onChanged;
  final List<String> currencies;

  const CurrencyInput(
      {Key? key, this.onChanged, this.currencies = defaultCurrencies})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CurrencyInputState();
  }
}

class CurrencyInputOutput {
  num amount;
  String currency;

  List<List<dynamic>> outputs = [];

  CurrencyInputOutput(this.amount, this.currency);
}

class _CurrencyInputState extends State<CurrencyInput> {
  StreamController<String> streamController = StreamController();
  final MoneyMaskedTextController _controller = MoneyMaskedTextController(
      initialValue: 0.0, decimalSeparator: '.', thousandSeparator: ',');
  num altValue = 0;
  String currCurrency = 'USD';
  String altCurrency = 'BTC';
  bool altValueLoading = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() async {
      widget.onChanged!(
          CurrencyInputOutput(_controller.numberValue, currCurrency));
      setState(() {
        altValueLoading = true;
      });
      altValue = (await getIt<CurrencyRepository>().getRate(
              currCurrency, altCurrency, _controller.numberValue, null))
          .amount;
      setState(() {
        altValue = altValue;
        altValueLoading = false;
      });
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

    List<MaterialState> negativeButtonState =
        negativeEnabled ? [] : [MaterialState.disabled];
    List<MaterialState> positiveButtonState =
        positiveEnabled ? [] : [MaterialState.disabled];

    return Row(children: <Widget>[
      Expanded(
        child: TextField(
          decoration: InputDecoration(
              prefixText: '\$',
              labelText: AppLocalizations.of(context)!.amount,
              helperText: altValueLoading
                  ? '...'
                  : FormatCurrency().format(altCurrency, altValue)),
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
            color: Theme.of(context)
                .elevatedButtonTheme
                .style!
                .foregroundColor!
                .resolve(Set.of(negativeButtonState)),
            icon: const Icon(Icons.remove),
          )),
      const SizedBox(
        width: padding / 2,
      ),
      Ink(
          decoration: buttonDecoration(context, positiveEnabled),
          child: IconButton(
            onPressed: () => updateValue(1),
            color: Theme.of(context)
                .elevatedButtonTheme
                .style!
                .foregroundColor!
                .resolve(Set.of(positiveButtonState)),
            icon: const Icon(Icons.add),
          ))
    ]);
  }
}
