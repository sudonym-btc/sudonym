import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sudonym/constants.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/presentation/pages/contact.dart';
import 'package:sudonym/presentation/pages/receive.dart';
import 'package:sudonym/presentation/pages/send.dart';
import 'package:sudonym/presentation/pages/send_confirm.dart';
import 'package:sudonym/presentation/pages/settings.dart';
import 'package:sudonym/presentation/pages/transaction.dart';
import 'package:sudonym/presentation/theme.dart';
import 'package:sudonym/presentation/widgets/status_page/status_page.dart';
import 'firebase_options.dart';
import 'presentation/widgets/auth/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  String? env = const String.fromEnvironment('ENV');
  if (env == "") {
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

// StatusPage(
//               pageTitle: '',
//               title: 'Payment failed',
//               subtitle: 'You don\'t have enough balance in your account',
//               icon: FontAwesomeIcons.exclamationCircle,
//               actions: ButtonBar(
//                 children: [
//                   ElevatedButton(
//                     child: Text('Retry'),
//                     style: raisedButtonStyle,
//                     onPressed: () {},
//                   )
//                 ],
//               ),
//               color: Colors.red,
//             ),