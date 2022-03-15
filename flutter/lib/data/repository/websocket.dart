import 'package:injectable/injectable.dart';
import 'package:web_socket_channel/io.dart';

import '../../injection.dart';

@prod
@Injectable(as: Websocket, env: [Env.prod])
class WebsocketImpl extends Websocket {
  WebsocketImpl() : super();

  IOWebSocketChannel channel =
      IOWebSocketChannel.connect(Uri.parse('ws://localhost:1234'));

  @override
  connect() {
    /// Listen for all incoming data
    channel.stream.listen(
      (data) {
        print(data);
      },
      onError: (error) => print(error),
    );
  }

  @override
  Stream getStream() => channel.stream;
}

abstract class Websocket {
  connect();
  Stream getStream();
}
