import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym/config/logger.dart';
import 'package:sudonym/logic/index.dart';
import 'package:web_socket_channel/io.dart';
import 'package:sudonym/config/config.dart';

import 'package:sudonym/injection.dart';

@Singleton(as: Websocket, env: Env.allButMock)
class WebsocketImpl extends Websocket with WebsocketLogger {
  Config config;
  StreamController stream = StreamController.broadcast();
  StreamSubscription? socketSubscription;
  IOWebSocketChannel? channel;

  WebsocketImpl(this.config) : super();

  @override
  disconnect() {
    if (socketSubscription != null) {
      socketSubscription!.cancel();
    }
  }

  @override
  connect() async {
    if (socketSubscription != null) {
      socketSubscription!.cancel();
    }
    Uri url = Uri.parse(
        '${config.apiUrl.replaceAll('http', 'ws')}:${config.websocketPort}/socket.io');

    loggy.info('Connecting websocket to $url');

    String bearer = await FirebaseAuth.instance.currentUser!.getIdToken();
    loggy.info(bearer);
    channel =
        IOWebSocketChannel.connect(url, headers: {'x-access-token': bearer});

    socketSubscription = channel!.stream.listen((event) {
      stream.sink.add(event);
    }, onError: (e) async {
      loggy.error(e);
      await Future.delayed(const Duration(seconds: 1));
      await connect();
    }, onDone: () async {
      await Future.delayed(const Duration(seconds: 1));
      await connect();
    }, cancelOnError: true);
  }

  @override
  Stream getStream() => stream.stream;
}

abstract class Websocket {
  connect();
  disconnect();
  Stream getStream();
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) =>
              true; // add your localhost detection logic here if you want
  }
}
