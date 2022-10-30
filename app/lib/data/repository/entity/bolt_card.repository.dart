import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/config/index.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';

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
  Function converter = (e) => BoltCard.fromJson(e);
}
