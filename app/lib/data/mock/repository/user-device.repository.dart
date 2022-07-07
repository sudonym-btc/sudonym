import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/config/config.dart';
import 'package:sudonym/data/repository/user-device.repository.dart';
import 'package:sudonym/injection.dart';

import '../../repository/websocket.dart';
import 'crud_repository.dart';

@LazySingleton(as: UserDeviceRepository, env: [Env.mock])
class MockUserDeviceRepository extends MockCrudRepository<UserDevice>
    with UserDeviceRepositoryProps
    implements UserDeviceRepository {
  MockUserDeviceRepository(Config config, Dio dio, Websocket websocket)
      : super(config, dio, websocket);
}
