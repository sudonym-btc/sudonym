import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:loggy/loggy.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/firebase_options.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/presentation/index.dart';

void main(List<String> args) {
  mainCommon(null);
}

void mainCommon(String? env) async {
  env = env ?? const String.fromEnvironment('ENV');
  env = env == '' ? Env.mock : env;

  // Allow self signed certificates for development
  if ([Env.mock, Env.dev, Env.test].contains(env)) {
    HttpOverrides.global = MyHttpOverrides();
  }

  Loggy.initLoggy(
    logPrinter: (kReleaseMode)
        ? const PrettyPrinter(showColors: true)
        : const PrettyPrinter(showColors: true),
  );

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  configureInjection(env);

  await SentryFlutter.init(
      (options) => options.dsn =
          'REDACTED_SENTRY_DSN',
      appRunner: () => runZonedGuarded(() async {
            runApp(const App());
          }, (error, stackTrace) {
            print('Error FROM OUT_SIDE FRAMEWORK ');
            print('--------------------------------');
            print('Error :  $error');
            print('StackTrace :  $stackTrace');
          }));

  FlutterError.onError = (details) => print(details);
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sudonym',
      theme: getTheme(),
      darkTheme: getTheme(light: false),
      home: const AuthGate(),
      // builder: (BuildContext context, Widget? widget) {
      //   ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      //     return StatusPage(
      //         title: 'Error',
      //         subtitle: 'Encountered an unrecoverable error',
      //         content: Text(errorDetails.toString()),
      //         color: Colors.red);
      //   };

      //   return widget!;
      // },
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routes: {
        '/receive': (context) => const ReceivePage(),
        '/settings': (context) => const SettingsPage(),
        '/contact': (context) => const ContactPage(),
        '/transaction': (context) => const TransactionPage()
      },
    );
  }
}
