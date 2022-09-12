import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:loggy/loggy.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/presentation/pages/contact.dart';
import 'package:sudonym/presentation/pages/receive.dart';
import 'package:sudonym/presentation/pages/send_confirm.dart';
import 'package:sudonym/presentation/pages/settings.dart';
import 'package:sudonym/presentation/pages/transaction.dart';
import 'package:sudonym/presentation/theme.dart';
import 'package:sudonym/presentation/widgets/status_page/status_page.dart';
import 'data/repository/websocket.dart';
import 'firebase_options.dart';
import 'presentation/widgets/auth/auth_gate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main(List<String> args) {
  mainCommon(null);
}

void mainCommon(String? env) async {
  env = env ?? const String.fromEnvironment('ENV');
  env = env == "" ? Env.mock : env;

  // Allow self signed certificates for development
  if ([Env.mock, Env.dev].contains(env)) {
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
    appRunner: () => runApp(const App()),
  );
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sudonym',
      theme: themeData,
      home: const AuthGate(),
      builder: (BuildContext context, Widget? widget) {
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          return StatusPage(
              title: "Error",
              subtitle: "Encountered an unrecoverable error",
              content: Text(errorDetails.toString()),
              color: Theme.of(context).errorColor);
        };

        return widget!;
      },
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routes: {
        '/receive': (context) => const ReceivePage(),
        '/confirmSend': (context) => const SendConfirmPage(),
        '/settings': (context) => const SettingsPage(),
        '/contact': (context) => const ContactPage(),
        '/transaction': (context) => const TransactionPage()
      },
    );
  }
}
