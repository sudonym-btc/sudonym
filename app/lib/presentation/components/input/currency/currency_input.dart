import 'dart:async';

import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudonym.models/types/currency.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:rxdart/rxdart.dart';

const List<String> defaultCurrencies = ['USD', 'BTC'];

class CurrencyInput extends FormField<CurrencyInputOutput> {
  final Function(CurrencyInputOutput)? onChanged;
  final List<String> currencies;
  final num min;
  late String? minCurrency;
  final num max;
  late String? maxCurrency;

  CurrencyInput(
      {super.key,
      this.minCurrency,
      this.min = 0,
      this.maxCurrency,
      this.max = 999999999,
      this.onChanged,
      this.currencies = defaultCurrencies}) : super(
    builder: (FormFieldState<CurrencyInputOutput> state) {
      return BlocProvider(
      create: (_) => getIt<CurrencyInputCubit>(),
      child: BlocBuilder<CurrencyInputCubit, CurrencyInputCubitState>(builder: (context, state) {


    }, ));
    }) {
        minCurrency ??= initialValue.currency;
        maxCurrency ??= initialValue.currency;
      }
}

class CurrencyInputOutput {
  num amount;
  String currency;
  CurrencyInputOutput(this.amount, this.currency);
}

class _CurrencyInputState extends State<CurrencyInput> {
  StreamController<num> streamController = StreamController();
  MoneyMaskedTextController _controller = MoneyMaskedTextController(
      initialValue: 0.0,
      decimalSeparator: '.',
      thousandSeparator: ',',
      precision: 2);

  num bounceValueBase = 1;
  num bounceValue = 1;

  num altValue = 0;
  int currCurrency = 0;
  int altCurrency = 1;

  bool altValueLoading = false;
  late Future<CurrencyResponse> output;
  late Future<CurrencyResponse> alt;

  setCurrentCurrency(int i) {
    setState(() {
      currCurrency = i >= widget.currencies.length ? 0 : i;
      altCurrency =
          currCurrency + 1 >= widget.currencies.length ? 0 : currCurrency + 1;

      bool switchedToBTC = widget.currencies[currCurrency] == 'BTC';
      if (switchedToBTC) {
        _controller = MoneyMaskedTextController(
            initialValue: altValue.toDouble() * SATOSHIS,
            decimalSeparator: '',
            thousandSeparator: ',',
            precision: 0);
      } else {
        _controller = MoneyMaskedTextController(
            initialValue: altValue.toDouble(),
            decimalSeparator: '.',
            thousandSeparator: ',',
            precision: 2);
      }
      listeners();
      streamController.add(_controller.numberValue);
    });
  }

  setNextCurrency() {
    setCurrentCurrency(currCurrency + 1);
  }

  listeners() {
    _controller
        .addListener(() => streamController.add(_controller.numberValue));
  }

  @override
  void initState() {
    super.initState();
    getIt<CurrencyRepository>()
        .getRate(
            fromCurrency: widget.initialValueCurrency,
            toCurrency: widget.currencies[currCurrency],
            amount: widget.initialValue != null
                ? widget.initialValue!
                : (widget.min ?? 0))
        .then((value) {
      _controller.updateValue(value.amount.toDouble());
    });

    listeners();

    streamController.stream
        .debounceTime(const Duration(milliseconds: 500))
        .asyncMap((e) async => await getValues(e))
        .listen((event) {
      print(event);
      print("output");
    });

    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (bounceValue > bounceValueBase) {
        bounceValue = bounceValue / 10;
      }
    });
  }

  getValues(value) {
    setState(() {
      altValueLoading = true;
    });
    output = getIt<CurrencyRepository>().getRate(
        fromCurrency: widget.currencies[currCurrency],
        toCurrency: widget.outputCurrency,
        amount: _controller.numberValue *
            (widget.currencies[currCurrency] == 'BTC' ? 1 / SATOSHIS : 1));

    alt = widget.currencies[altCurrency] == widget.outputCurrency
        ? output
        : getIt<CurrencyRepository>().getRate(
            fromCurrency: widget.currencies[currCurrency],
            toCurrency: widget.currencies[altCurrency],
            amount: _controller.numberValue *
                (widget.currencies[currCurrency] == 'BTC' ? 1 / SATOSHIS : 1));

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

  updateValue(num v) {
    bounceValue = bounceValue * 10;
    if (_controller.numberValue + v < (widget.min ?? 0)) {
      return _controller.updateValue((widget.min ?? 0).toDouble());
    }
    _controller.updateValue(_controller.numberValue + v);
  }

  @override
  Widget build(BuildContext context) {
    bool negativeEnabled = output. > (widget.min ?? 0);
    bool positiveEnabled = _controller.numberValue < (widget.max ?? 99999999);

    List<MaterialState> negativeButtonState =
        negativeEnabled ? [] : [MaterialState.disabled];
    List<MaterialState> positiveButtonState =
        positiveEnabled ? [] : [MaterialState.disabled];

    Ink negativeButton = Ink(
        decoration: buttonDecoration(context, negativeEnabled),
        child: IconButton(
          onPressed: negativeEnabled
              ? () => updateValue(-bounceValueBase * bounceValue)
              : null,
          color: Theme.of(context)
              .elevatedButtonTheme
              .style!
              .foregroundColor!
              .resolve(Set.of(negativeButtonState)),
          icon: const Icon(Icons.remove),
        ));
    Ink positiveButton = Ink(
        decoration: buttonDecoration(context, positiveEnabled),
        child: IconButton(
          onPressed: positiveEnabled
              ? () => updateValue(bounceValue * bounceValue)
              : null,
          color: Theme.of(context)
              .elevatedButtonTheme
              .style!
              .foregroundColor!
              .resolve(Set.of(positiveButtonState)),
          icon: const Icon(Icons.add),
        ));

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      Expanded(
        child: TextField(
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
              // constraints: BoxConstraints(minHeight: 60, maxHeight: 60),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              prefixText:
                  '${getCurrencySymbol(widget.currencies[currCurrency])}  ',
              prefixStyle: TextStyle(),
              // suffixText: widget.currencies[altCurrency],
              // suffixStyle: const TextStyle(fontSize: 10),
              suffixIcon: IconButton(
                iconSize: 24,
                onPressed: setNextCurrency,
                icon: Icon(
                  Icons.swap_vert,
                  color: Theme.of(context).primaryColor,
                ),
              ),
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
      negativeButton,
      const SizedBox(
        width: padding / 2,
      ),
      positiveButton
    ]);
  }
}
