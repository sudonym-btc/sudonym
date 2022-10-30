import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym/config/logger.dart';
import 'package:native_flutter_proxy/native_proxy_reader.dart';
import 'package:web_socket_channel/io.dart';
import 'package:sudonym/config/index.dart';

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

    loggy.i('Connecting websocket to $url');

    String bearer = await FirebaseAuth.instance.currentUser!.getIdToken();
    channel =
        IOWebSocketChannel.connect(url, headers: {'x-access-token': bearer});

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
    NativeProxyReader.proxySetting.then((value) {
      proxy = value;
    });

    return super.createHttpClient(context)
      ..findProxy = (url) {
        if (proxy != null && proxy.host != null && proxy.port != null) {
          return 'PROXY ${proxy.host}:${proxy.port}';
        } else {
          return 'DIRECT';
        }
      }
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) =>
              true; // add your localhost detection logic here if you want
  }
}
