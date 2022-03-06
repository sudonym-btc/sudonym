import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sudonym/injection.dart';
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
        theme: ThemeData(fontFamily: 'Satoshi'),
        home: const AuthGate());
  }
}
