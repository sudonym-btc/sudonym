import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/user-device.dart';
import 'package:sudonym/config/config.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';

@LazySingleton(as: UserDeviceRepository, env: Env.allButMock)
class UserDeviceRepositoryImpl extends UserDeviceRepository {
  UserDeviceRepositoryImpl(Config config, Dio dio, Websocket websocket)
      : super(config, dio, websocket);
}

abstract class UserDeviceRepository extends CrudRepository<UserDevice>
    with UserDeviceRepositoryProps {
  UserDeviceRepository(Config config, Dio dio, Websocket websocket)
      : super(config, dio, websocket);
}

class UserDeviceRepositoryProps {
  @override
  String get endpoint => "userDevice";

  @override
  Function converter = (e) => UserDevice.fromJson(e);
}
