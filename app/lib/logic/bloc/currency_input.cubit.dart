import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym.models/index.dart';

const List<String> defaultCurrencies = ['USD', 'BTC'];

class CurrencyInputController {
  late CurrencyInputOutput value;
  StreamController<CurrencyInputOutput> outputStream =
      StreamController.broadcast();

  CurrencyInputController() {
    outputStream.stream.listen((event) {
      value = event;
    });
  }
}

class CurrencyInputOptions {
  CurrencyInputController? controller;
  List<String> currencies;
  String? initialCurrency;
  String? outputCurrency;
  Duration? debounceOutput;
  CurrencyInputOutput initialValue;
  List<CurrencyInputOutput>? min;
  List<CurrencyInputOutput>? max;

  CurrencyInputOptions(
      {this.controller,
      required this.initialValue,
      this.min,
      this.max,
      this.debounceOutput,
      this.currencies = defaultCurrencies,
      this.initialCurrency}) {
    min ??= List.empty();
    max ??= List.empty();
    initialCurrency ??= initialValue.currency;
    controller ??= CurrencyInputController();
    currencies = currencies.toSet().toList(); // Deduplicate
    debounceOutput ??= const Duration(milliseconds: 0);
  }
}

@injectable
class CurrencyInputCubit extends Cubit<CurrencyInputCubitState> with SafeEmit {
  final CurrencyRepository _currencyRespository = getIt<CurrencyRepository>();
  final CurrencyInputOptions options;
  MoneyMaskedTextController? controller;

  num clickValueBase = 1;

  CurrencyInputCubit(this.options) : super(const CurrencyInputCubitState()) {
    options.controller!.outputStream.stream
        .map((event) => event.amount)
        .distinct()
        .asyncMap(enforceConstraints)
        .asyncMap(resolveAlt)
        .debounceTime(options.debounceOutput!)
        .listen((event) {});
    setCurrentCurrency(options.currencies.indexOf(options.initialCurrency!));
    _currencyRespository
        .getRate(
            fromCurrency: options.initialValue.currency,
            toCurrency: options.initialCurrency!,
            amount: options.initialValue.amount)
        .then((value) {
      controller!.updateValue(getDisplayValue(
          options.currencies[state.currCurrency], value.amount));
      setValue(value.amount);
    });
  }

  createController() {
    int wantedPrecision =
        options.currencies[state.currCurrency] == 'BTC' ? 0 : 2;

    if (controller?.precision != wantedPrecision) {
      controller = MoneyMaskedTextController(
          initialValue: state.currVal.toDouble() ?? 0.0,
          decimalSeparator: wantedPrecision > 0 ? '.' : '',
          thousandSeparator: ',',
          precision: wantedPrecision)
        ..addListener(() => setValue(getRealValue(
            options.currencies[state.currCurrency], controller!.numberValue)));
      safeEmit(state.copyWith());
    }
  }

  setCurrentCurrency(int i) {
    num newCurrVal =
        getDisplayValue(options.currencies[state.altCurrency], state.altVal);
    int newCurr = i >= state.currencies.length ? 0 : i;
    safeEmit(state.copyWith(
        currCurrency: newCurr,
        altCurrency: newCurr + 1 >= state.currencies.length ? 0 : newCurr + 1,
        altVal: 0,
        minLoading: true,
        maxLoading: true,
        altLoading: true));
    createController();
    controller!.updateValue(newCurrVal.toDouble());
    setValue(getRealValue(
        options.currencies[state.currCurrency], controller!.numberValue));
    clickValueBase = options.currencies[state.currCurrency] == 'BTC' ? 1000 : 1;
  }

  toggleCurrency() {
    setCurrentCurrency(state.currCurrency + 1);
  }

  Future<num> enforceConstraints(num val) async {
    safeEmit(state.copyWith(minLoading: true));
    double min = await getMinInCurrentCurrency();
    if (numToCurrentPrecision(min) >= numToCurrentPrecision(val)) {
      controller!.updateValue(
          getDisplayValue(options.currencies[state.currCurrency], min));
      setValue(min); // Must set true value as dislay value is vague
      safeEmit(state.copyWith(negativeEnabled: false));
    } else {
      safeEmit(state.copyWith(negativeEnabled: true));
    }
    safeEmit(state.copyWith(minLoading: false));

    safeEmit(state.copyWith(maxLoading: true));
    double max = await getMaxInCurrentCurrency();

    if (min > max) {
      safeEmit(state.copyWith(error: 'Max amount is less than minimum'));
      return val;
    } else {
      safeEmit(state.copyWith(error: null));
    }

    if (numToCurrentPrecision(max) <= numToCurrentPrecision(val)) {
      controller!.updateValue(
          getDisplayValue(options.currencies[state.currCurrency], max));
      setValue(max); // Must set true value as dislay value is vague
      safeEmit(state.copyWith(positiveEnabled: false));
    } else {
      safeEmit(state.copyWith(positiveEnabled: true));
    }
    safeEmit(state.copyWith(maxLoading: false));
    return val;
  }

  Future<num> resolveAlt(num val) async {
    // Loading the alt currency value
    safeEmit(
        state.copyWith(minLoading: true, maxLoading: true, altLoading: true));
    _currencyRespository
        .getRate(
            fromCurrency: options.currencies[state.currCurrency],
            toCurrency: options.currencies[state.altCurrency],
            amount: val)
        .then((value) {
      safeEmit(state.copyWith(altVal: value.amount, altLoading: false));
    });
    return val;
  }

  setValue(num val) {
    options.controller!.outputStream
        .add(CurrencyInputOutput(val, options.currencies[state.currCurrency]));
    safeEmit(state.copyWith(currVal: val.toDouble()));
  }

  getMultiplier([bool incrementing = true]) {
    double currVal = getCurrentDisplayValue();
    if (!incrementing) {
      // If subtracting, the multiplier should be subtracted before entering the next order of magnitude to not jump straight to zero
      currVal -= 0.0001;
    }

    int multiplier =
        (currVal / clickValueBase).floor().toStringAsFixed(0).length;
    return max(0, multiplier - 1);
  }

  Future<double> getMinInCurrentCurrency() async {
    if (options.min == null || options.min!.isEmpty) return 0;
    return (await Future.wait(options.min!.map((e) =>
            _currencyRespository.getRate(
                fromCurrency: e.currency,
                toCurrency: options.currencies[state.currCurrency],
                amount: e.amount))))
        .map((e) => e.amount)
        .reduce(max)
        .toDouble();
  }

  double numToCurrentPrecision(num input) {
    return num.parse(input.toStringAsFixed(
            options.currencies[state.currCurrency] == 'BTC' ? 8 : 2))
        .toDouble();
  }

  Future<double> getMaxInCurrentCurrency() async {
    if (options.max == null || options.max!.isEmpty) return 9999999999999;
    return (await Future.wait(options.max!.map((e) =>
            _currencyRespository.getRate(
                fromCurrency: e.currency,
                toCurrency: options.currencies[state.currCurrency],
                amount: e.amount))))
        .map((e) => e.amount)
        .reduce(min)
        .toDouble();
  }

  incrementValue() async {
    num clickVal = (clickValueBase * pow(10, getMultiplier()));
    num newVal = getCurrentDisplayValue() + clickVal;
    newVal = (newVal / clickVal).round() * clickVal;
    controller!.updateValue(min(
        getDisplayValue(options.currencies[state.currCurrency],
            await getMaxInCurrentCurrency()),
        newVal.toDouble()));
  }

  decrementValue() async {
    num clickVal = (clickValueBase * pow(10, getMultiplier(false)));
    num newVal = getCurrentDisplayValue() - clickVal;

    newVal = (numToCurrentPrecision(newVal / clickVal)).ceil() *
        clickVal; // should be display precision
    controller!.updateValue(max(
        getDisplayValue(options.currencies[state.currCurrency],
            await getMinInCurrentCurrency()),
        newVal.toDouble()));
  }

  // Convert display value in sats to BTC value
  getRealValue(String curr, num value) {
    return value / (curr == 'BTC' ? SATOSHIS : 1);
  }

  double getCurrentDisplayValue() {
    return getDisplayValue(
        options.currencies[state.currCurrency], state.currVal);
  }

  double getDisplayValue(String curr, num value) {
    return (value * (curr == 'BTC' ? SATOSHIS : 1)).toDouble();
  }
}

class CurrencyInputCubitState extends Equatable {
  final List<String> currencies;
  final bool positiveEnabled;
  final bool negativeEnabled;
  final bool maxLoading;
  final bool minLoading;
  final bool altLoading;
  final int currCurrency;
  final int altCurrency;
  final num currVal;
  final num altVal;
  final String? error;

  const CurrencyInputCubitState({
    this.currencies = defaultCurrencies,
    this.positiveEnabled = false,
    this.negativeEnabled = false,
    this.maxLoading = false,
    this.minLoading = false,
    this.altLoading = false,
    this.currCurrency = 0,
    this.altCurrency = 1,
    this.currVal = 0,
    this.altVal = 0,
    this.error,
  });

  CurrencyInputCubitState copyWith(
          {List<String>? currencies,
          bool? positiveEnabled,
          bool? negativeEnabled,
          bool? maxLoading,
          bool? minLoading,
          bool? altLoading,
          int? currCurrency,
          int? altCurrency,
          num? currVal,
          num? altVal,
          String? error}) =>
      CurrencyInputCubitState(
          currencies: currencies ?? this.currencies,
          positiveEnabled: positiveEnabled ?? this.positiveEnabled,
          negativeEnabled: negativeEnabled ?? this.negativeEnabled,
          maxLoading: maxLoading ?? this.maxLoading,
          minLoading: minLoading ?? this.minLoading,
          altLoading: altLoading ?? this.altLoading,
          currCurrency: currCurrency ?? this.currCurrency,
          altCurrency: altCurrency ?? this.altCurrency,
          currVal: currVal ?? this.currVal,
          altVal: altVal ?? this.altVal,
          error: error ?? this.error);

  @override
  List<Object?> get props => [
        positiveEnabled,
        negativeEnabled,
        maxLoading,
        minLoading,
        altLoading,
        currCurrency,
        altCurrency,
        currVal,
        altVal,
        error
      ];
}
