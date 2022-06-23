import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/presentation/pages/contact.dart';
import 'package:sudonym/presentation/pages/receive.dart';
import 'package:sudonym/presentation/pages/send.dart';
import 'package:sudonym/presentation/pages/send_confirm.dart';
import 'package:sudonym/presentation/pages/settings.dart';
import 'package:sudonym/presentation/pages/transaction.dart';
import 'package:sudonym/presentation/theme.dart';
import 'firebase_options.dart';
import 'presentation/widgets/auth/auth_gate.dart';

void main(List<String> args) {
  mainCommon(null);
}

void mainCommon(String? env) async {
  env = env ?? const String.fromEnvironment('ENV');
  env = env == "" ? Env.mock : env;

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  configureInjection(env);
  runApp(const App());
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
      routes: {
        '/receive': (context) => const ReceivePage(),
        '/send': (context) => const SendPage(),
        '/confirmSend': (context) => const SendConfirmPage(),
        '/settings': (context) => const SettingsPage(),
        '/contact': (context) => const ContactPage(),
        '/transaction': (context) => const TransactionPage()
      },
    );
  }
}
