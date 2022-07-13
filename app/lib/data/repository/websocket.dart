import 'dart:async';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:sudonym/config/repository-logger.dart';
import 'package:web_socket_channel/io.dart';
import 'package:sudonym/config/config.dart';

import '../../injection.dart';

@Singleton(as: Websocket, env: Env.allButMock)
class WebsocketImpl extends Websocket with WebsocketLogger {
  Config config;
  StreamController stream = StreamController.broadcast();

  WebsocketImpl(this.config) : super();

  @override
  connect() {
    Uri url = Uri.parse(
        config.apiUrl.replaceAll('https', 'wss').replaceAll('http', 'ws') +
            ':' +
            config.websocketPort.toString() +
            "/socket.io");

    loggy.info("Connecting websocket to " + url.toString());

    IOWebSocketChannel channel = IOWebSocketChannel.connect(url);

    // Listen for all incoming data

    stream.addStream(channel.stream);

    stream.stream.listen((e) {
      loggy.error(e);
    });

    getStream().handleError((event) {
      loggy.error(event);
    });
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
