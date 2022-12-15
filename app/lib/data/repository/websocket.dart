import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';
import 'package:native_flutter_proxy/native_proxy_reader.dart';
import 'package:sudonym/config/index.dart';
import 'package:sudonym/injection.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

@Singleton(as: Websocket, env: Env.allButMock)
class WebsocketImpl extends Websocket
    with WebsocketLogger, WidgetsBindingObserver {
  Config config;
  StreamController stream = StreamController.broadcast();
  StreamSubscription? socketSubscription;
  StreamSubscription? pingSubscription;
  WebSocketChannel? channel;
  int _errorCount = 0;
  DateTime? lastPing;
  Timer? checker;
  List<String> acked = [];
  WebsocketImpl(this.config) : super() {
    WidgetsFlutterBinding.ensureInitialized();
    WidgetsBinding.instance.addObserver(this);
    pingSubscription = stream.stream.listen((event) {
      if (event['ping'] != null) {
        // loggy.v('websocket ping received');
        lastPing = DateTime.now();
      }
    });

    checker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (lastPing != null &&
          DateTime.now().difference(lastPing!).inSeconds > 5) {
        lastPing = DateTime.now();
        loggy.i('Websocket reconnecting due to periodic checker');
        forceReconnect();
      }
    });
  }

  @override
  disconnect() {
    if (channel != null) channel = null;
    if (socketSubscription != null) {
      loggy.d('Disconnecting websocket');
      socketSubscription!.cancel();
    }
  }

  @override
  connect() async {
    if (channel != null) return;
    Uri url = Uri.parse(
            '${config.apiUrl.replaceAll('http', 'ws')}:${config.websocketPort}/socket.io')
        .replace(queryParameters: {
      'x-access-token': await FirebaseAuth.instance.currentUser?.getIdToken()
    });

    loggy.d('Connecting websocket to $url');

    channel = WebSocketChannel.connect(url);

    socketSubscription = channel!.stream.listen(onReceived,
        onError: onError, onDone: () => onError(null), cancelOnError: true);
  }

  @override
  forceReconnect() async {
    disconnect();
    connect();
  }

  void onReceived(dynamic msg) {
    _errorCount = 0;
    var event = jsonDecode(msg);
    if (event['id'] != null) {
      if (!acked.contains(event['id'])) {
        stream.sink.add(event);
        ack(event['id']);
      }
    }
  }

  void ack(messageId) {
    acked.add(messageId);
    if (channel != null) {
      channel?.sink.add(jsonEncode({
        'id': messageId,
        'event': 'ack',
      }));
    }
  }

  void onError(dynamic e) async {
    loggy.e(e);
    await Future.delayed(Duration(milliseconds: 500 * _errorCount));
    _errorCount++;
    loggy.i('Websocket reconnecting due to error');
    await connect();
  }

  @override
  Stream getStream() => stream.stream;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    loggy.v('Changed app state registered in websocket');
    if (state == AppLifecycleState.resumed) {
      loggy.i('Websocket reconnecting due to state change');
      forceReconnect();
    }
  }

  void dispose() {
    if (checker != null) checker!.cancel();
    if (pingSubscription != null) pingSubscription!.cancel();
    disconnect();
    loggy.d('Websocket disposed');
    WidgetsBinding.instance.removeObserver(this);
  }
}

abstract class Websocket {
  connect();
  forceReconnect();
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
