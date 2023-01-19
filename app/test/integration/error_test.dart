import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym.models/index.dart';

void main() {
  final getIt = GetIt.instance;

  setUpAll(() {
    configureInjection(Env.mock);
  });

  testWidgets('should show error with correct title', (tester) async {
    Payment p = Payment.fromJson({
      'originalAddress': 'lnurl23423432',
      'address': 'lnurl23423432',
      'amount': 1,
      'currency': 1,
      'type': 'pay',
      'isLnUrl': true,
      'isBolt11': false,
      'remoteResponses': [
        {
          'success': true,
          'data': {'maxSendable': 100000, 'minSendable': 10000}
        }
      ]
    });
    await tester.pumpWidget(
        MaterialApp(
            title: 'demo',
            theme: getTheme(),
            home: PayInfoPage(
                onDone: (p) {},
                onError: (e) {},
                pot: (getIt<PotRepository>() as MockPotRepository)
                    .availableData[0],
                action: p)),
        const Duration(seconds: 5));
    print('done here');
  });
}
