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
  final num? min;
  final num? max;
  late String? minCurrency;
  late String? maxCurrency;
  CurrencyInputOutput initialValue;

  CurrencyInputOptions(
      {this.controller,
      required this.initialValue,
      this.min = 0,
      this.max = 999999999,
      this.minCurrency,
      this.maxCurrency,
      this.currencies = defaultCurrencies}) {
    minCurrency ??= initialValue.currency;
    maxCurrency ??= initialValue.currency;
    controller ??= CurrencyInputController();
    currencies = currencies.toSet().toList();
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
        .distinct()
        .map((event) => event.amount)
        .debounceTime(const Duration(milliseconds: 500))
        .asyncMap(resolveValues)
        .listen((event) {});
    setCurrentCurrency(
        options.currencies.indexOf(options.initialValue.currency));
    controller!.updateValue(getDisplayValue(
        options.currencies[state.currCurrency], options.initialValue.amount));
    setValue(options.initialValue.amount);
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

  resolveValues(num val) {
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

    _currencyRespository
        .getRate(
            fromCurrency: options.currencies[state.currCurrency],
            toCurrency: options.minCurrency!,
            amount: val)
        .then((value) {
      safeEmit(state.copyWith(
          negativeEnabled: value.amount > options.min!, minLoading: false));
    });

    _currencyRespository
        .getRate(
            fromCurrency: options.currencies[state.currCurrency],
            toCurrency: options.maxCurrency!,
            amount: val)
        .then((value) {
      safeEmit(state.copyWith(
          positiveEnabled: options.max == null || value.amount < options.max!,
          maxLoading: false));
    });
  }

  setValue(num val) {
    options.controller!.outputStream
        .add(CurrencyInputOutput(val, options.currencies[state.currCurrency]));
    safeEmit(state.copyWith(currVal: val.toDouble()));
  }

  getMultiplier() {
    int multiplier = (getDisplayValue(
                options.currencies[state.currCurrency], state.currVal) /
            clickValueBase)
        .toStringAsFixed(0)
        .length;
    return max(0, multiplier - 1);
  }

  incrementValue() async {
    num clickVal = (clickValueBase * pow(10, getMultiplier()));
    num newVal =
        getDisplayValue(options.currencies[state.currCurrency], state.currVal) +
            clickVal;
    newVal = (newVal / clickVal).ceil() * clickVal;
    controller!.updateValue(min(
        getDisplayValue(options.currencies[state.currCurrency], await getMax()),
        newVal.toDouble()));
  }

  Future<double> getMin() async {
    return ((options.min ?? 0) *
            (await _currencyRespository.getRate(
                    fromCurrency: options.maxCurrency ??
                        options.currencies[state.currCurrency],
                    toCurrency: options.currencies[state.currCurrency]))
                .amount)
        .toDouble();
  }

  Future<double> getMax() async {
    return ((options.max ?? 9999999999999) *
            (await _currencyRespository.getRate(
                    fromCurrency: options.maxCurrency ??
                        options.currencies[state.currCurrency],
                    toCurrency: options.currencies[state.currCurrency]))
                .amount)
        .toDouble();
  }

  decrementValue() async {
    num clickVal = (clickValueBase * pow(10, getMultiplier()));
    num newVal =
        getDisplayValue(options.currencies[state.currCurrency], state.currVal) -
            clickVal;
    newVal = (newVal / clickVal).floor() * clickVal;
    controller!.updateValue(max(
        getDisplayValue(options.currencies[state.currCurrency], await getMin()),
        newVal.toDouble()));
  }

  // Convert display value in sats to BTC value
  getRealValue(String curr, num value) {
    return value / (curr == 'BTC' ? SATOSHIS : 1);
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
          num? altVal}) =>
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
          altVal: altVal ?? this.altVal);

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
        altVal
      ];
}
