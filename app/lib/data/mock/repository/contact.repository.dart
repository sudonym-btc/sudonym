import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/contact.dart';
import 'package:sudonym/config/config.dart';
import 'package:sudonym/data/repository/contact.repository.dart';

import '../../../injection.dart';
import '../../repository/websocket.dart';
import 'crud_repository.dart';

@Injectable(as: ContactRepository, env: [Env.mock])
class MockContactRepository extends crud_repository<Contact>
    implements ContactRepository {
  @override
  String get endpoint => "contact";

  MockContactRepository(Config config, Dio dio, Websocket websocket)
      : super(config, dio, websocket);
}
