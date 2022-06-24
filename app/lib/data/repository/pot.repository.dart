import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/pot.dart';
import 'package:sudonym/data/repository/crud_repository.dart';
import 'package:sudonym/data/repository/websocket.dart';

import '../../injection.dart';

@Injectable(as: PotRepository, env: Env.allButMock)
class PotRepositoryImpl extends PotRepository {
  @override
  String get endpoint => "pot";

  @override
  Function converter = Pot.fromJson;

  PotRepositoryImpl(Dio dio, Websocket websocket) : super(dio, websocket);
}

abstract class PotRepository extends crud_repository<Pot> {
  PotRepository(Dio dio, Websocket websocket) : super(dio, websocket);
}
