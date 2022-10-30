import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym/config/config.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym.models/user.dart';

@LazySingleton(as: UserRepository, env: [Env.mock])
class MockUserRepository extends MockCrudRepository<User>
    with UserRepositoryProps
    implements UserRepository {
  MockUserRepository(Config config, Dio dio, Websocket websocket)
      : super(config, dio, websocket);
}
