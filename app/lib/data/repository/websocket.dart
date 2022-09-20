import 'dart:async';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:sudonym/config/logger.dart';
import 'package:web_socket_channel/io.dart';
import 'package:sudonym/config/config.dart';

import '../../injection.dart';

@Singleton(as: Websocket, env: Env.allButMock)
class WebsocketImpl extends Websocket with WebsocketLogger {
  Config config;
  StreamController stream = StreamController.broadcast();
  StreamSubscription? socketSubscription;
  IOWebSocketChannel? channel;

  WebsocketImpl(this.config) : super();

  @override
  connect() {
    if (socketSubscription != null) {
      socketSubscription!.cancel();
    }
    Uri url = Uri.parse(
        '${config.apiUrl.replaceAll('http', 'ws')}:${config.websocketPort}/socket.io');

    loggy.info('Connecting websocket to $url');

    channel = IOWebSocketChannel.connect(url);

    socketSubscription = channel!.stream.listen((event) {
      stream.sink.add(event);
    }, onError: (e) async {
      loggy.error(e);
      await Future.delayed(const Duration(seconds: 1));
      connect();
    }, onDone: () async {
      await Future.delayed(const Duration(seconds: 1));
      connect();
    }, cancelOnError: true);
  }

  @override
  Stream getStream() => stream.stream;
}

abstract class Websocket {
  connect();
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
