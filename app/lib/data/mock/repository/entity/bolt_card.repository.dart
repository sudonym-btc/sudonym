import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/config/config.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';

import 'crud_repository.dart';

@LazySingleton(as: BoltCardRepository, env: [Env.mock])
class MockBoltCardRepository extends MockCrudRepository<BoltCard>
    with BoltCardRepositoryProps
    implements BoltCardRepository {
  MockBoltCardRepository(Config config, Dio dio, Websocket websocket)
      : super(config, dio, websocket);
}
