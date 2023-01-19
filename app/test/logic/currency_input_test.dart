import 'package:flutter_test/flutter_test.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';

void main() {
  setUpAll(() {
    configureInjection(Env.mock);
  });
  group('Currency Input', () {
    test('should set initial value as first output', () async {
      final cubit = CurrencyInputCubit(
          CurrencyInputOptions(initialValue: CurrencyValue(1, 'BTC')));

      var output = await cubit.options.controller!.outputStream.stream.first;

      expect(output, equals(CurrencyValue(1, 'BTC')));
    });

    test('should set initial value in different currency as first output',
        () async {
      final cubit = CurrencyInputCubit(CurrencyInputOptions(
          initialValue: CurrencyValue(1, 'BTC'), initialCurrency: 'GBP'));

      var output = await cubit.options.controller!.outputStream.stream.first;

      var wantedOutput = CurrencyValue(
          (await getIt<CurrencyRepository>()
                  .getRate(fromCurrency: 'BTC', amount: 1, toCurrency: 'GBP'))
              .amount,
          'GBP');

      expect(output, equals(wantedOutput));
    });

    test('should not output first change if second change soon follows',
        () async {
      final cubit = CurrencyInputCubit(
          CurrencyInputOptions(initialValue: CurrencyValue(1, 'BTC')));

      await cubit.options.controller!.outputStream.stream.first;

      cubit.setValue(CurrencyValue(2, 'BTC'));
      cubit.setValue(CurrencyValue(3, 'BTC'));

      var output = await cubit.options.controller!.outputStream.stream.first;

      expect(output, equals(CurrencyValue(3, 'BTC')));
    });

    test('should set value to max restraint if trying to go higher', () async {
      final cubit = CurrencyInputCubit(
        CurrencyInputOptions(
            initialValue: CurrencyValue(1, 'BTC'),
            max: [CurrencyValue(2, 'BTC')]),
      );

      await cubit.options.controller!.outputStream.stream.first;

      cubit.setValue(CurrencyValue(3, 'BTC'));

      var output = await cubit.options.controller!.outputStream.stream.first;

      expect(output, equals(CurrencyValue(2, 'BTC')));

      await cubit.incrementValue();
      output = await cubit.options.controller!.outputStream.stream.first;

      expect(output, equals(CurrencyValue(2, 'BTC')));
    });

    test('should set value to min if trying to go lower', () async {
      final cubit = CurrencyInputCubit(
        CurrencyInputOptions(
            initialValue: CurrencyValue(2, 'BTC'),
            min: [CurrencyValue(1, 'BTC')]),
      );

      await cubit.options.controller!.outputStream.stream.first;

      cubit.setValue(CurrencyValue(0, 'BTC'));

      var output = await cubit.options.controller!.outputStream.stream.first;

      expect(output, equals(CurrencyValue(1, 'BTC')));

      await cubit.decrementValue();
      output = await cubit.options.controller!.outputStream.stream.first;

      expect(output, equals(CurrencyValue(1, 'BTC')));
    });

    test('should output new currency', () async {
      final cubit = CurrencyInputCubit(
        CurrencyInputOptions(
            initialValue: CurrencyValue(2, 'BTC'),
            min: [CurrencyValue(1, 'BTC')]),
      );

      await cubit.options.controller!.outputStream.stream.first;

      cubit.setValue(CurrencyValue(0, 'BTC'));

      var output = await cubit.options.controller!.outputStream.stream.first;

      expect(output, equals(CurrencyValue(1, 'BTC')));

      await cubit.decrementValue();
      output = await cubit.options.controller!.outputStream.stream.first;

      expect(output, equals(CurrencyValue(1, 'BTC')));
    });
  });
}
