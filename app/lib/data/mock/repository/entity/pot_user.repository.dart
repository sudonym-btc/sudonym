import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym/config/index.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym.models/index.dart';

@LazySingleton(as: PotUserRepository, env: [Env.mock])
class MockPotUserRepository extends MockCrudRepository<PotUser>
    with PotUserRepositoryProps
    implements PotUserRepository {
  MockPotUserRepository(Config config, Dio dio, Websocket websocket)
      : super(config, dio, websocket);
}
