import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym/config/index.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym.models/index.dart';

@LazySingleton(as: PotUserRepository, env: Env.allButMock)
class PotUserRepositoryImpl extends PotUserRepository {
  PotUserRepositoryImpl(Config config, Dio dio, Websocket websocket)
      : super(config, dio, websocket);
}

abstract class PotUserRepository extends CrudRepository<PotUser>
    with PotRepositoryProps {
  PotUserRepository(Config config, Dio dio, Websocket websocket)
      : super(config, dio, websocket);
}

class PotUserRepositoryProps {
  String get endpoint => 'potUser';
  Function converter = (e) => Pot.fromJson(e);
}
