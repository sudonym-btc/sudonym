import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/user.dart';
import 'package:sudonym/data/repository/crud_repository.dart';
import 'package:sudonym/data/repository/websocket.dart';

import '../../injection.dart';

@Injectable(as: UserRepository, env: Env.allButMock)
class UserRepositoryImpl extends UserRepository {
  @override
  String get endpoint => "user";
  @override
  Function converter = User.fromJson;

  UserRepositoryImpl(Dio dio, Websocket websocket) : super(dio, websocket);

}

abstract class UserRepository extends crud_repository<User> {
  UserRepository(Dio dio, Websocket websocket) : super(dio, websocket);
}
