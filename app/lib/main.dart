import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:loggy/loggy.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/presentation/pages/contact.dart';
import 'package:sudonym/presentation/pages/receive.dart';
import 'package:sudonym/presentation/pages/send.dart';
import 'package:sudonym/presentation/pages/send_confirm.dart';
import 'package:sudonym/presentation/pages/settings.dart';
import 'package:sudonym/presentation/pages/transaction.dart';
import 'package:sudonym/presentation/theme.dart';
import 'package:sudonym/presentation/widgets/status_page/status_page.dart';
import 'data/repository/websocket.dart';
import 'firebase_options.dart';
import 'presentation/widgets/auth/auth_gate.dart';

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
    logPrinter: (kReleaseMode) ? PrettyPrinter() : PrettyPrinter(),
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

class MessageHandler extends StatefulWidget {
  Widget child;
  MessageHandler({required this.child, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MessageHandlerState();
}

class _MessageHandlerState extends State<MessageHandler> {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  @override
  initState() {
    print("Init State");
    super.initState();

    _fcm.requestPermission();

    _fcm.onTokenRefresh.listen((event) {
      print(event);
    });

    // FirebaseMessaging.onBackgroundMessage((e) async {
    //   print(e.toString());
    // });

    FirebaseMessaging.instance.getToken().then(print);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      importance: Importance.max,
    );
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

// getInitialMessage(): If the application is opened from a terminated state a Future containing a RemoteMessage will be returned. Once consumed, the RemoteMessage will be removed
    FirebaseMessaging.onMessage.listen((event) {
      print("Notification clicked & app = closed");
    });
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      print("Notification clicked & app was in background");
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
