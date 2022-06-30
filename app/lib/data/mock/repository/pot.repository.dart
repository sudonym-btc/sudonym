import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/pot.dart';
import 'package:sudonym/config/config.dart';
import 'package:sudonym/data/repository/pot.repository.dart';

import '../../../injection.dart';
import '../../repository/websocket.dart';
import 'crud_repository.dart';

@Injectable(as: PotRepository, env: [Env.mock])
class MockPotRepository extends crud_repository<Pot> implements PotRepository {
  @override
  String get endpoint => "pot";

  MockPotRepository(Config config, Dio dio, Websocket websocket)
      : super(config, dio, websocket);
}
