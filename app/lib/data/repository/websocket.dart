import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:native_flutter_proxy/native_proxy_reader.dart';
import 'package:sudonym/config/index.dart';

import 'package:sudonym/injection.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

@Singleton(as: Websocket, env: Env.allButMock)
class WebsocketImpl extends Websocket with WebsocketLogger {
  Config config;
  StreamController stream = StreamController.broadcast();
  StreamSubscription? socketSubscription;
  WebSocketChannel? channel;

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
            '${config.apiUrl.replaceAll('http', 'ws')}:${config.websocketPort}/socket.io')
        .replace(queryParameters: {
      'x-access-token': await FirebaseAuth.instance.currentUser!.getIdToken()
    });

    loggy.i('Connecting websocket to $url');

    channel = WebSocketChannel.connect(url);

    socketSubscription = channel!.stream.listen((event) {
      stream.sink.add(event);
    }, onError: (e) async {
      loggy.e(e);
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

dynamic proxy;

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);

    // If not running as web app, check device proxy settings
    // incase traffic needs to be routed from physical device to local development server
    if (!kIsWeb) {
      NativeProxyReader.proxySetting.then((value) {
        proxy = value;
      });
      client.findProxy = (url) {
        if (proxy != null && proxy.host != null && proxy.port != null) {
          return 'PROXY ${proxy.host}:${proxy.port}';
        } else {
          return 'DIRECT';
        }
      };
    }

    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) =>
            true; // add your localhost detection logic here if you want

    return client;
  }
}
