import 'dart:async';
import 'dart:math';

import 'package:injectable/injectable.dart';
import 'package:web_socket_channel/io.dart';
import 'package:sudonym/config/config.dart';

import '../../injection.dart';

@Singleton(as: Websocket, env: Env.allButMock)
class WebsocketImpl extends Websocket {
  Config config;
  StreamController stream = StreamController.broadcast();

  WebsocketImpl(this.config) : super();

  @override
  connect() {
    Uri url = Uri.parse(
        config.apiUrl.replaceAll('https', 'wss').replaceAll('http', 'ws') +
            ':' +
            config.websocketPort.toString());

    print("Connecting websocket to " + url.toString());

    IOWebSocketChannel channel = IOWebSocketChannel.connect(url);

    // Listen for all incoming data

    stream.addStream(channel.stream);

    getStream().handleError((event) {
      print(event);
    });
  }

  @override
  Stream getStream() => stream.stream;
}

abstract class Websocket {
  connect();
  Stream getStream();
}
