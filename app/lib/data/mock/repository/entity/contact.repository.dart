import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/config/index.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';

@LazySingleton(as: ContactRepository, env: [Env.mock])
class MockContactRepository extends MockCrudRepository<Contact>
    with ContactRepositoryProps
    implements ContactRepository {
  MockContactRepository(Config config, Dio dio, Websocket websocket)
      : super(config, dio, websocket);
}
