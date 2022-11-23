import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym/config/index.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym.models/index.dart';

@LazySingleton(as: PotRepository, env: Env.allButMock)
class PotRepositoryImpl extends PotRepository {
  PotRepositoryImpl(Config config, Dio dio, Websocket websocket)
      : super(config, dio, websocket);
}

abstract class PotRepository extends CrudRepository<Pot>
    with PotRepositoryProps {
  PotRepository(Config config, Dio dio, Websocket websocket)
      : super(config, dio, websocket);
}

class PotRepositoryProps {
  String get endpoint => 'pot';
  Pot Function(Map<String, dynamic>) converter = (e) => Pot.fromJson(e);
}
