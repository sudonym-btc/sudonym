import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym/config/index.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym.models/index.dart';

@Injectable(as: BoltCardRepository, env: Env.allButMock)
class BoltCardRepositoryImpl extends BoltCardRepository {
  BoltCardRepositoryImpl(Config config, Dio dio, Websocket websocket)
      : super(config, dio, websocket);
}

abstract class BoltCardRepository extends CrudRepository<BoltCard>
    with BoltCardRepositoryProps {
  BoltCardRepository(Config config, Dio dio, Websocket websocket)
      : super(config, dio, websocket);
}

class BoltCardRepositoryProps {
  String endpoint = 'boltCard';
  BoltCard Function(Map<String, dynamic>) converter =
      (e) => BoltCard.fromJson(e);
}
