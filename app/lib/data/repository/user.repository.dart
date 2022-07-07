import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/user.dart';
import 'package:sudonym/config/config.dart';
import 'package:sudonym/data/repository/crud_repository.dart';
import 'package:sudonym/data/repository/websocket.dart';

import '../../injection.dart';

@LazySingleton(as: UserRepository, env: Env.allButMock)
class UserRepositoryImpl extends UserRepository {
  UserRepositoryImpl(Config config, Dio dio, Websocket websocket)
      : super(config, dio, websocket);
}

abstract class UserRepository extends CrudRepository<User>
    with UserRepositoryProps {
  UserRepository(Config config, Dio dio, Websocket websocket)
      : super(config, dio, websocket);
}

class UserRepositoryProps {
  @override
  String get endpoint => "user";
  @override
  Function converter = (e) => User(e);
}
