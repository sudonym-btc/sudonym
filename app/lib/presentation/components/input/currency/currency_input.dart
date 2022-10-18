import 'dart:async';

import 'package:dio/dio.dart';
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sudonym.models/types/currency.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/logic/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sudonym/presentation/index.dart';

const List<String> defaultCurrencies = ['USD', 'BTC'];

class CurrencyInput extends StatefulWidget {
  final Function(CurrencyInputOutput)? onChanged;
  final List<String> currencies;
  final num? min;
  final num? max;
  final num? initialValue;
  final String initialValueCurrency;
  final String outputCurrency;

  const CurrencyInput(
      {Key? key,
      this.initialValueCurrency = 'BTC',
      this.initialValue,
      this.min,
      this.max,
      this.onChanged,
      this.outputCurrency = 'BTC',
      this.currencies = defaultCurrencies})
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
  StreamController<num> streamController = StreamController();
  final MoneyMaskedTextController _controller = MoneyMaskedTextController(
      initialValue: 0.0, decimalSeparator: '.', thousandSeparator: ',');
  num altValue = 0;
  int currCurrency = 0;
  int altCurrency = 1;
  bool altValueLoading = false;
  late Future<CurrencyResponse> output;
  late Future<CurrencyResponse> alt;

  @override
  void initState() {
    super.initState();
    getIt<CurrencyRepository>()
        .getRate(
            widget.initialValueCurrency,
            widget.currencies[currCurrency],
            widget.initialValue != null
                ? widget.initialValue!
                : (widget.min ?? 0),
            null)
        .then((value) {
      _controller.updateValue(value.amount.toDouble());
    });

    _controller.addListener(() {
      streamController.add(_controller.numberValue);
    });

    streamController.stream
        .transform(StreamTransformer.fromHandlers(handleData: (data, sink) {
          setState(() {
            altValueLoading = true;
          });
          sink.add(data);
        }))
        .asyncMap((e) async => await getValues(e))
        .listen((event) {
          print(event);
          print("output");
        });
    // .pipe((element) {
    //   print(element);
    //   setState(() {
    //     altValueLoading = true;
    //   });
    //   return element;
    // })
    // .asStream()
    // .forEach((element) {
    //   print(element);
    // })
    // .asStream()
    // .asyncMap((e) async => await getValues(e))
    // .listen((event) {
    //   print(event);
    // });
  }

  getValues(value) {
    output = getIt<CurrencyRepository>().getRate(
        widget.currencies[currCurrency],
        widget.outputCurrency,
        _controller.numberValue,
        null);

    alt = widget.currencies[altCurrency] == widget.outputCurrency
        ? output
        : getIt<CurrencyRepository>().getRate(widget.currencies[currCurrency],
            widget.currencies[altCurrency], _controller.numberValue, null);

    output.then((value) {
      widget
          .onChanged!(CurrencyInputOutput(value.amount, widget.outputCurrency));
    });

    alt.then((value) => {
          setState(
            () {
              altValue = value.amount;
              altValueLoading = false;
            },
          )
        });
  }

  @override
  Widget build(BuildContext context) {
    updateValue(num v) {
      if (_controller.numberValue <= 0 && v <= 0) return;
      _controller.updateValue(_controller.numberValue + v);
    }

    bool negativeEnabled = _controller.numberValue > (widget.min ?? 0);
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
                  : FormatCurrency()
                      .format(widget.currencies[altCurrency], altValue)),
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
            onPressed: positiveEnabled ? () => updateValue(1) : null,
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
