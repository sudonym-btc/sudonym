import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym/config/config.dart';
import 'package:sudonym/data/repository/user.repository.dart';
import 'package:sudonym/injection.dart';

import '../../repository/websocket.dart';
import 'crud_repository.dart';
import 'package:sudonym.models/user.dart';

@Injectable(as: UserRepository, env: [Env.mock])
class MockUserRepository extends crud_repository<User>
    implements UserRepository {
  @override
  String get endpoint => "user";

  MockUserRepository(Config config, Dio dio, Websocket websocket)
      : super(config, dio, websocket);
}
