import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/presentation/pages/home_page.dart';
import 'package:sudonym/presentation/pages/receive.dart';
import 'package:sudonym/presentation/pages/send.dart';
import 'firebase_options.dart';
import 'presentation/widgets/auth/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  configureInjection(Env.dev);
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
        tabBarTheme: TabBarTheme(labelColor: Colors.black),
        appBarTheme: const AppBarTheme(
          foregroundColor: Colors.black,
          toolbarTextStyle: TextStyle(color: Colors.black),
          titleTextStyle: TextStyle(color: Colors.black),
          iconTheme: IconThemeData(color: Colors.black),
          actionsIconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          elevation: 0
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                shadowColor:
                    MaterialStateProperty.all<Color>(Colors.transparent))),
        fontFamily: 'Satoshi',
        backgroundColor: Colors.white,
      ),
      home: const AuthGate(),
      routes: {
        '/receive': (context) => const ReceivePage(),
        '/send': (context) => const SendPage(),
      },
    );
  }
}
