import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym/config/index.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym.models/index.dart';

@LazySingleton(as: SenderRepository, env: Env.allButMock)
class SenderRepositoryImpl extends SenderRepository {
  SenderRepositoryImpl(Config config, Dio dio, Websocket websocket)
      : super(config, dio, websocket);
}

abstract class SenderRepository extends CrudRepository<Sender>
    with SenderRepositoryProps {
  SenderRepository(Config config, Dio dio, Websocket websocket)
      : super(config, dio, websocket);
}

class SenderRepositoryProps {
  String get endpoint => 'sender';
  Sender Function(Map<String, dynamic>) converter = (e) => Sender.fromJson(e);
}
