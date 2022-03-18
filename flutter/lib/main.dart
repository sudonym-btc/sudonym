import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:sudonym/constants.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/presentation/pages/receive.dart';
import 'package:sudonym/presentation/pages/send.dart';
import 'package:sudonym/presentation/pages/send_confirm.dart';
import 'package:sudonym/presentation/pages/settings.dart';
import 'firebase_options.dart';
import 'presentation/widgets/auth/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  String? env = const String.fromEnvironment('ENV');
  if(env == "") {
    env = Env.mock;
  }
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
      theme: ThemeData(
        tabBarTheme: TabBarTheme(labelColor: textColor),
        appBarTheme: const AppBarTheme(
            foregroundColor: textColor,
            toolbarTextStyle: TextStyle(color: textColor),
            titleTextStyle: TextStyle(color: textColor),
            iconTheme: IconThemeData(color: textColor),
            actionsIconTheme: IconThemeData(color: textColor),
            backgroundColor: Colors.white,
            elevation: 0),
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
                foregroundColor: MaterialStateProperty.resolveWith<Color?>((s) {
                  if (s.contains(MaterialState.disabled))
                    return Colors.black; // Disabled button color
                  return Colors.white; // Enabled button color
                }),
                backgroundColor: MaterialStateProperty.resolveWith<Color?>((s) {
                  if (s.contains(MaterialState.disabled))
                    return primary.shade100; // Disabled button color
                  return primary; // Enabled button color
                }),
                shadowColor:
                    MaterialStateProperty.all<Color>(Colors.transparent))),
        fontFamily: 'Satoshi',
        backgroundColor: Colors.white,
      ),
      home: const AuthGate(),
      routes: {
        '/receive': (context) => const ReceivePage(),
        '/send': (context) => const SendPage(),
        '/confirmSend': (context) => const SendConfirmPage(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}
