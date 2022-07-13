import 'package:loggy/loggy.dart';

mixin RepoLogger implements LoggyType {
  @override
  Loggy<RepoLogger> get loggy =>
      Loggy<RepoLogger>('Repo Logger - $runtimeType');
}

mixin ListLogger implements LoggyType {
  @override
  Loggy<ListLogger> get loggy =>
      Loggy<ListLogger>('List Logger - $runtimeType');
}

mixin WebsocketLogger implements LoggyType {
  @override
  Loggy<WebsocketLogger> get loggy =>
      Loggy<WebsocketLogger>('Websocket Logger - $runtimeType');
}
