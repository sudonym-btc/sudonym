import 'dart:async';

import 'package:injectable/injectable.dart';

import 'package:sudonym/injection.dart';
import 'package:sudonym/data/repository/websocket.dart';

@Singleton(as: Websocket, env: [Env.mock])
class MockWebsocket extends Websocket {
  StreamController<dynamic> stream = StreamController.broadcast();

  @override
  Stream getStream() => stream.stream;

  @override
  connect() {}

  @override
  disconnect() {}
}
