import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/pot.dart';
import 'package:sudonym/config/config.dart';
import 'package:sudonym/data/repository/pot.repository.dart';

import '../../../injection.dart';
import '../../repository/websocket.dart';
import 'crud_repository.dart';

@LazySingleton(as: PotRepository, env: [Env.mock])
class MockPotRepository extends MockCrudRepository<Pot>
    with PotRepositoryProps
    implements PotRepository {
  MockPotRepository(Config config, Dio dio, Websocket websocket)
      : super(config, dio, websocket);
}
