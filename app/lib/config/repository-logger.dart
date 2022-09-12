import 'package:loggy/loggy.dart' show Loggy, LoggyType;

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

mixin ActionLogger implements LoggyType {
  @override
  Loggy<ActionLogger> get loggy =>
      Loggy<ActionLogger>('Action Logger - $runtimeType');
}

mixin AmountLogger implements LoggyType {
  @override
  Loggy<AmountLogger> get loggy =>
      Loggy<AmountLogger>('Amount Logger - $runtimeType');
}

mixin WebsocketLogger implements LoggyType {
  @override
  Loggy<WebsocketLogger> get loggy =>
      Loggy<WebsocketLogger>('Websocket Logger - $runtimeType');
}

mixin NotificationLogger implements LoggyType {
  @override
  Loggy<NotificationLogger> get loggy =>
      Loggy<NotificationLogger>('Notification Logger - $runtimeType');
}
