import 'package:injectable/injectable.dart';

import '../../../injection.dart';
import '../../repository/websocket.dart';

@Injectable(as: Websocket, env: [Env.mock])
class MockWebsocket extends Websocket {
  Stream<dynamic> stream = const Stream<dynamic>.empty();

  @override
  Stream getStream() => stream;

  @override
  connect() {}
}
