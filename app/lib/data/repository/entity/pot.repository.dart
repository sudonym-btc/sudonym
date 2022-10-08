import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/pot.dart';
import 'package:sudonym/config/config.dart';
import 'package:sudonym/data/repository/websocket.dart';
import 'package:sudonym/injection.dart';
import 'crud_repository.dart';

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
  @override
  String get endpoint => "pot";
  @override
  Function converter = (e) => Pot.fromJson(e);
}
