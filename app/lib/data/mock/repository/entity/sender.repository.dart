import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym/config/index.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym.models/index.dart';

@LazySingleton(as: SenderRepository, env: [Env.mock])
class MockSenderRepository extends MockCrudRepository<Sender>
    with SenderRepositoryProps
    implements SenderRepository {
  MockSenderRepository(Config config, Dio dio, Websocket websocket)
      : super(config, dio, websocket);
}
