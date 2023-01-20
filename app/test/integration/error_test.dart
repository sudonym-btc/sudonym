import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sudonym/data/dio/error.interceptor.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym.models/index.dart';

const errorString = 'This was the reason';

DioError errorObj = DioError(
    requestOptions: RequestOptions(path: 'test'),
    response: Response(
        requestOptions: RequestOptions(path: 'test'),
        data: LNURLProtocolError(errorString)));

DioError errorObjPreParse = DioError(
    requestOptions: RequestOptions(path: 'test'),
    response: Response(
        requestOptions: RequestOptions(path: 'test'),
        data: {'code': LNURLProtocolError.code, 'data': errorString}));

class MockTestActionRepository extends MockActionRepository {
  MockTestActionRepository(
      super.receiveRepository, super.transactionRepository, super.dio);

  @override
  Future<ActionParseResponse> parse(action) async {
    throw errorObj;
  }

  @override
  Future<Payment> getPaymentInfo(Payment action) async {
    throw errorObj;
  }

  @override
  Future<Withdraw> getWithdrawInfo(Withdraw action) async {
    throw errorObj;
  }

  @override
  Future<Transaction> pay(Payment action) async {
    throw errorObj;
  }

  @override
  Future<Receiver> withdraw(Withdraw action) async {
    throw LNURLProtocolError(errorString);
  }
}

void main() {
  final getIt = GetIt.instance;

  setUpAll(() {
    configureInjection(Env.mock);
  });

  group('LNURL', () {
    setUpAll(() {
      GetIt.instance.unregister<ActionRepository>();
      GetIt.instance.registerSingleton<ActionRepository>(
          MockTestActionRepository(getIt<ReceiverRepository>(),
              getIt<TransactionRepository>(), getIt<Dio>()));
    });

    test('should cast error type', () async {
      ErrorInterceptor interceptor = ErrorInterceptor();
      var handler = ErrorInterceptorHandler();
      interceptor.onError(errorObjPreParse, handler);
      var x = await handler.future.asStream().first.catchError((y) => y);
      expect(x.data.response.data, isA<LNURLProtocolError>());
      expect(x.data.response.data.data, equals(errorString));
    });
    test('should not cast non-app-error type', () async {
      ErrorInterceptor interceptor = ErrorInterceptor();
      var e = DioError(
          requestOptions: RequestOptions(path: 'test'),
          response: Response(
              requestOptions: RequestOptions(path: 'test'),
              data: {'code': 'random', 'data': errorString}));
      var handler = ErrorInterceptorHandler();
      interceptor.onError(e, handler);
      var x = await handler.future.asStream().first.catchError((y) => y);
      expect(x.data.response.data, isA<Map>());
    });
    testWidgets('should show error with correct title', (tester) async {
      Payment p = Payment.fromJson({
        'originalAddress': 'lnurl23423432',
        'address': 'lnurl23423432',
        'potId':
            (getIt<PotRepository>() as MockPotRepository).availableData[0].id,
        'amount': 1,
        'currency': 'BTC',
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
              debugShowCheckedModeBanner: false,
              title: 'Sudonym',
              theme: getTheme(),
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en'),
                Locale('es'),
                Locale('de'),
              ],
              darkTheme: getTheme(light: false),
              home: PayInfoPage(
                  onDone: (p) {},
                  onError: (e) {},
                  pot: (getIt<PotRepository>() as MockPotRepository)
                      .availableData[0],
                  action: p)),
          const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(find.text(errorString), findsOneWidget);
    });
  });
}
