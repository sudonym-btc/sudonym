import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sudonym/config/logger.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/injection.dart';

class MessageHandler extends StatefulWidget {
  final Widget child;
  const MessageHandler({required this.child, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MessageHandlerState();
}

class _MessageHandlerState extends State<MessageHandler>
    with NotificationLogger {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final UserDeviceRepository _userDeviceRepo = getIt<UserDeviceRepository>();
  final AuthCubit _authCubit = getIt<AuthCubit>();

  handleToken(String token) {
    // _authCubit.stream.listen(((event) {
    //   print(event);
    //   event.user;
    // }));
    _userDeviceRepo.create({'uid': _authCubit.state.user!.id, 'token': token});
    loggy.d('Got new notification token $token');
  }

  @override
  initState() {
    super.initState();

    _fcm.requestPermission();

    FirebaseMessaging.instance.getToken().then((t) {
      handleToken(t!);
    });

    _fcm.onTokenRefresh.listen((event) {
      handleToken(event);
    });

    // App running in background when notification received
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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
      loggy.d('Notification clicked & app = closed');
    });
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      loggy.d('Notification clicked & app was in background');
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}
