import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/pot.dart';
import 'package:sudonym/config/config.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';

@LazySingleton(as: PotRepository, env: [Env.mock])
class MockPotRepository extends MockCrudRepository<Pot>
    with PotRepositoryProps
    implements PotRepository {
  MockPotRepository(Config config, Dio dio, Websocket websocket)
      : super(config, dio, websocket);
}
