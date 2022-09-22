import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/contact.dart';
import 'package:sudonym/config/config.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';

import 'crud_repository.dart';

@LazySingleton(as: ContactRepository, env: [Env.mock])
class MockContactRepository extends MockCrudRepository<Contact>
    with ContactRepositoryProps
    implements ContactRepository {
  MockContactRepository(Config config, Dio dio, Websocket websocket)
      : super(config, dio, websocket);
}
