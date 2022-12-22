import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sudonym/config/index.dart';
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
class CurrencyInputCubit extends Cubit<CurrencyInputCubitState>
    with SafeEmit, AmountLogger {
  final CurrencyRepository _currencyRespository = getIt<CurrencyRepository>();
  final CurrencyInputOptions options;
  MoneyMaskedTextController? controller;

  num clickValueBase = 1;

  CurrencyInputCubit(this.options) : super(const CurrencyInputCubitState()) {
    options.controller!.outputStream.stream
        .map((event) => event.amount)
        .distinct()
        .debounceTime(options.debounceOutput!)
        .asyncMap(enforceConstraints)
        .asyncMap(resolveAlt)
        .listen((event) {});
    setCurrentCurrency(options.currencies.indexOf(options.initialCurrency!));
    _currencyRespository
        .getRate(
            fromCurrency: options.initialValue.currency,
            toCurrency: options.initialCurrency!,
            amount: options.initialValue.amount)
        .then((value) {
      controller!
          .updateValue(getDisplayValue(getCurrentCurrency(), value.amount));
      setValue(value.amount);
    });
  }

  createController() {
    int wantedPrecision = getCurrentCurrency() == 'BTC' ? 0 : 2;

    if (controller?.precision != wantedPrecision) {
      controller = MoneyMaskedTextController(
          initialValue: state.currVal.toDouble() ?? 0.0,
          decimalSeparator: wantedPrecision > 0 ? '.' : '',
          thousandSeparator: ',',
          precision: wantedPrecision)
        ..addListener(() => setValue(
            getRealValue(getCurrentCurrency(), controller!.numberValue)));
      safeEmit(state.copyWith());
    }
  }

  setCurrentCurrency(int i) {
    num newCurrVal = getDisplayValue(getAltCurrency(), state.altVal);
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
    setValue(getRealValue(getCurrentCurrency(), controller!.numberValue));
    clickValueBase = getCurrentCurrency() == 'BTC' ? 1000 : 1;
  }

  toggleCurrency() {
    setCurrentCurrency(state.currCurrency + 1);
  }

  Future<num> enforceConstraints(num val) async {
    safeEmit(state.copyWith(hasError: false));
    safeEmit(state.copyWith(minLoading: true));
    Map<String, dynamic>? error;
    double min = await getMinInCurrentCurrency();

    // Disable decrement button when already at minimum
    // controller!.updateValue(
    //     getDisplayValue(getCurrentCurrency(), min));
    // setValue(min); // Must set true value as dislay value is vague
    safeEmit(state.copyWith(
        negativeEnabled:
            numToCurrentPrecision(val) > numToCurrentPrecision(min)));

    // Return error when below minimum
    if (val < min) {
      error = {'min': FormatCurrency().format(getCurrentCurrency(), min)};
    }
    safeEmit(state.copyWith(minLoading: false));

    safeEmit(state.copyWith(maxLoading: true));
    double max = await getMaxInCurrentCurrency();

    if (min > max) {
      safeEmit(state.copyWith(
          hasError: true,
          error: {'max': FormatCurrency().format(getCurrentCurrency(), max)}));
      return val;
    }

    safeEmit(state.copyWith(
        positiveEnabled:
            numToCurrentPrecision(max) < numToCurrentPrecision(val)));

    if (numToCurrentPrecision(max) <= numToCurrentPrecision(val)) {
      controller!.updateValue(getDisplayValue(getCurrentCurrency(), max));
      setValue(max); // Must set true value as dislay value is vague
      safeEmit(state.copyWith(positiveEnabled: false));
    } else {
      safeEmit(state.copyWith(positiveEnabled: true));
    }
    safeEmit(state.copyWith(maxLoading: false));
    safeEmit(state.copyWith(hasError: error != null, error: error));
    return val;
  }

  Future<num> resolveAlt(num val) async {
    // Loading the alt currency value
    safeEmit(
        state.copyWith(minLoading: true, maxLoading: true, altLoading: true));
    _currencyRespository
        .getRate(
            fromCurrency: getCurrentCurrency(),
            toCurrency: getAltCurrency(),
            amount: val)
        .then((value) {
      safeEmit(state.copyWith(altVal: value.amount, altLoading: false));
    });
    return val;
  }

  setValue(num val) {
    options.controller!.outputStream
        .add(CurrencyInputOutput(val, getCurrentCurrency()));
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
                toCurrency: getCurrentCurrency(),
                amount: e.amount))))
        .map((e) => e.amount)
        .reduce(max)
        .toDouble();
  }

  double numToCurrentPrecision(num input) {
    return num.parse(
            input.toStringAsFixed(getCurrentCurrency() == 'BTC' ? 8 : 2))
        .toDouble();
  }

  Future<double> getMaxInCurrentCurrency() async {
    if (options.max == null || options.max!.isEmpty) return 9999999999999;
    return (await Future.wait(options.max!.map((e) =>
            _currencyRespository.getRate(
                fromCurrency: e.currency,
                toCurrency: getCurrentCurrency(),
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
        getDisplayValue(getCurrentCurrency(), await getMaxInCurrentCurrency()),
        newVal.toDouble()));
  }

  decrementValue() async {
    num clickVal = (clickValueBase * pow(10, getMultiplier(false)));
    num newVal = getCurrentDisplayValue() - clickVal;

    newVal = (numToCurrentPrecision(newVal / clickVal)).ceil() *
        clickVal; // should be display precision
    double min = await getMinInCurrentCurrency();
    double val =
        max(min, getRealValue(getCurrentCurrency(), newVal.toDouble()));
    double valDisplay =
        max(getDisplayValue(getCurrentCurrency(), min), newVal.toDouble());

    controller!.updateValue(valDisplay);
    setValue(val); // Must set exact value too due to precision
  }

  // Convert display value in sats to BTC value
  getRealValue(String curr, num value) {
    return value / (curr == 'BTC' ? SATOSHIS : 1);
  }

  String getCurrentCurrency() {
    return options.currencies[state.currCurrency];
  }

  String getAltCurrency() {
    return options.currencies[state.altCurrency];
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
  final Map<String, dynamic>? error;

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
          bool? hasError,
          Map<String, dynamic>? error}) =>
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
          error: hasError == false ? null : error ?? this.error);

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
