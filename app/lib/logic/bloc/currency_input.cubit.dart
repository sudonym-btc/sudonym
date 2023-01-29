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
  CurrencyValue value;
  StreamController<CurrencyValue> outputStream = StreamController.broadcast();
  StreamController<CurrencyValue> maskedInputStream = StreamController();
  BehaviorSubject<CurrencyValue> inputStream = BehaviorSubject();
  StreamController<CurrencyValue> processingStream =
      StreamController.broadcast();

  CurrencyInputController(this.value) {
    outputStream.stream.listen((event) {
      value = event;
    });
  }
}

class CurrencyInputOptions {
  CurrencyInputController? controller;
  List<String> currencies;
  bool showAltCurrency;
  bool enabled;
  bool canSwitchCurrency;
  String? initialCurrency;
  String? outputCurrency;
  Duration? debounceOutput;
  CurrencyValue initialValue;
  List<CurrencyValue>? min;
  List<CurrencyValue>? max;

  CurrencyInputOptions(
      {this.controller,
      required this.initialValue,
      this.min,
      this.max,
      this.enabled = true,
      this.canSwitchCurrency = true,
      this.showAltCurrency = true,
      this.debounceOutput,
      this.currencies = defaultCurrencies,
      this.initialCurrency}) {
    min ??= List.empty();
    max ??= List.empty();
    initialCurrency ??= initialValue.currency;
    controller ??= CurrencyInputController(initialValue);
    currencies = {
      ...currencies,
      ...defaultCurrencies,
      initialValue.currency,
      if (initialCurrency != null) initialCurrency!
    }.toList(); // Deduplicate
    debounceOutput ??= const Duration(milliseconds: 0);
  }
}

@injectable
class CurrencyInputCubit extends Cubit<CurrencyInputCubitState>
    with SafeEmit, AmountLogger {
  final CurrencyRepository _currencyRespository = getIt<CurrencyRepository>();
  final CurrencyInputOptions options;
  MoneyMaskedTextController? controller;
  late num id;

  num clickValueBase = 1;
  num changeCount = 0;

  CurrencyInputCubit(this.options)
      : super(CurrencyInputCubitState(options: options)) {
    id = new DateTime.now().millisecondsSinceEpoch;
    setCurrentCurrency(options.currencies.indexOf(options.initialCurrency!));

    options.controller!.maskedInputStream.stream.listen((event) {
      loggy.d('Manual input');
      loggy.d(event);
      options.controller!.inputStream.add(event);
    });

    options.controller!.inputStream.stream
        .distinct()
        .doOnData((event) {
          safeEmit(state.copyWith(altLoading: true));
        })
        .switchMap(resolveAlt)
        .doOnData((event) {
          safeEmit(state.copyWith(altVal: event.amount, altLoading: false));
        })
        .listen((event) {});

    options.controller!.inputStream.stream
        // .debounceTime(options.debounceOutput!)
        .map((event) {
          event.id = changeCount++;
          return event;
        })
        .doOnData(quietInputUpdate)
        .switchMap(enforceConstraints)
        .doOnData((event) {
          loggy.d('Input has been updated to $event');
        })
        .listen((event) {
          options.controller!.outputStream.add(event);
          options.controller!.processingStream.add(event);
        });
    safeEmit(state.copyWith(maxLoading: true, minLoading: true));
    _currencyRespository
        .getRate(
            fromCurrency: options.initialValue.currency,
            toCurrency: options.initialCurrency!,
            amount: options.initialValue.amount)
        .then((value) {
      safeEmit(state.copyWith(maxLoading: false, minLoading: false));

      setValue(CurrencyValue(value.amount, options.initialCurrency!));
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
        ..addListener(inputChangeHandler);
      safeEmit(state.copyWith());
    }
  }

  inputChangeHandler() {
    options.controller!.maskedInputStream.add(CurrencyValue(
        getRealValue(getCurrentCurrency(), controller!.numberValue),
        getCurrentCurrency()));
  }

  quietInputUpdate(CurrencyValue val) {
    controller!.removeListener(inputChangeHandler);
    controller!
        .updateValue(getDisplayValue(val.currency, val.amount).toDouble());
    controller!.addListener(inputChangeHandler);
  }

  setCurrentCurrency(int i) {
    int newCurr = i >= options.currencies.length ? 0 : i;
    safeEmit(state.copyWith(
        currCurrency: newCurr,
        altCurrency:
            newCurr + 1 >= options.currencies.length ? 0 : newCurr + 1));
    createController();
    clickValueBase = getCurrentCurrency() == 'BTC' ? 1000 : 1;

    // If next currency value is set, convert current val
    if (state.altVal != null) {
      num newCurrVal = state.altVal!;
      setValue(CurrencyValue(newCurrVal, getCurrentCurrency()));
    }
  }

  toggleCurrency() {
    setCurrentCurrency(state.currCurrency + 1);
  }

  Stream<CurrencyValue> enforceConstraints(CurrencyValue val) async* {
    safeEmit(
        state.copyWith(hasError: false, minLoading: true, maxLoading: true));
    Map<String, dynamic>? error;
    double min = await getMinInCurrentCurrency();
    CurrencyValue response = val;

    bool positiveEnabled = true;
    bool negativeEnabled = true;

    negativeEnabled =
        numToCurrentPrecision(val.amount) > numToCurrentPrecision(min);

    // Return error when below minimum, round to 8 decimal places to avoid small deviations
    if (num.parse(val.amount.toStringAsFixed(8)) <
        num.parse(min.toStringAsFixed(8))) {
      error = {'min': FormatCurrency().format(getCurrentCurrency(), min)};
    }
    double max = await getMaxInCurrentCurrency();

    if (min > max) {
      error = {
        'constraints': FormatCurrency().format(getCurrentCurrency(), max)
      };
    }

    positiveEnabled =
        numToCurrentPrecision(val.amount) < numToCurrentPrecision(max);
    if (!positiveEnabled) {
      // loggy.d('Quietly updating right here to ' + max.toString());
      quietInputUpdate(CurrencyValue(max,
          getCurrentCurrency())); // Must set true value as dislay value is vague
      response = CurrencyValue(max, getCurrentCurrency(), val.id);
    } else if (!negativeEnabled) {
      // Dont update the input here though, because 0 must be available to start typing new number
      response = CurrencyValue(min, getCurrentCurrency(), val.id);
    }

    safeEmit(state.copyWith(
        maxLoading: false,
        minLoading: false,
        positiveEnabled: state.options.enabled && positiveEnabled,
        negativeEnabled: state.options.enabled && negativeEnabled,
        currVal: response.amount,
        hasError: error != null,
        error: error));
    yield response;
  }

  Stream<CurrencyResponse> resolveAlt(CurrencyValue val) async* {
    CurrencyResponse value = await _currencyRespository.getRate(
        fromCurrency: getCurrentCurrency(),
        toCurrency: getAltCurrency(),
        amount: val.amount);
    yield value;
  }

  Future<void> setValue(CurrencyValue val) async {
    options.controller!.inputStream.add(val);
    await options.controller!.processingStream.stream
        .firstWhere((event) => event.id >= val.id);
  }

  setEnabled(bool enabled) {
    safeEmit(state.copyWith(enabled: enabled));
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
    setValue(CurrencyValue(
      min(await getMaxInCurrentCurrency(),
          getRealValue(getCurrentCurrency(), newVal).toDouble()),
      getCurrentCurrency(),
    ));
  }

  decrementValue() async {
    num clickVal = (clickValueBase * pow(10, getMultiplier(false)));
    num newVal = getCurrentDisplayValue() - clickVal;

    newVal = (numToCurrentPrecision(newVal / clickVal)).ceil() *
        clickVal; // should be display precision

    setValue(CurrencyValue(
        max(await getMinInCurrentCurrency(),
            getRealValue(getCurrentCurrency(), newVal.toDouble())),
        getCurrentCurrency())); // Must set exact value too due to precision
  }

  // Convert display value in sats to BTC value
  double getRealValue(String curr, num value) {
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

  void triggerState() {
    safeEmit(state);
  }
}

class CurrencyInputCubitState extends Equatable {
  final CurrencyInputOptions options;
  final List<String> currencies;
  final bool enabled;
  final bool positiveEnabled;
  final bool negativeEnabled;
  final bool maxLoading;
  final bool minLoading;
  final bool altLoading;
  final int currCurrency;
  final int altCurrency;
  final num currVal;
  final num? altVal;
  final Map<String, dynamic>? error;

  const CurrencyInputCubitState({
    required this.options,
    this.currencies = defaultCurrencies,
    this.enabled = true,
    this.positiveEnabled = false,
    this.negativeEnabled = false,
    this.maxLoading = false,
    this.minLoading = false,
    this.altLoading = false,
    this.currCurrency = 0,
    this.altCurrency = 1,
    this.currVal = 0,
    this.altVal,
    this.error,
  });

  CurrencyInputCubitState copyWith(
          {CurrencyInputOptions? options,
          List<String>? currencies,
          bool? enabled,
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
          options: options ?? this.options,
          currencies: currencies ?? this.currencies,
          enabled: enabled ?? this.enabled,
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
        options,
        enabled,
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
