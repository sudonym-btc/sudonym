import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/config/config.dart';
import 'package:sudonym/data/repository/bolt_card.repository.dart';

import '../../../injection.dart';
import '../../repository/websocket.dart';
import 'crud_repository.dart';

@LazySingleton(as: BoltCardRepository, env: [Env.mock])
class MockBoltCardRepository extends MockCrudRepository<BoltCard>
    with BoltCardRepositoryProps
    implements BoltCardRepository {
  MockBoltCardRepository(Config config, Dio dio, Websocket websocket)
      : super(config, dio, websocket);
}
