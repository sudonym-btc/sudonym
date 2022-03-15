import 'package:injectable/injectable.dart';

import '../../../injection.dart';
import '../../repository/websocket.dart';

@dev
@Injectable(as: Websocket, env: [Env.dev])
class MockWebsocket extends Websocket {
  Stream<dynamic> stream = const Stream<dynamic>.empty();

  @override
  Stream getStream() => stream;

  @override
  connect() {}
}
