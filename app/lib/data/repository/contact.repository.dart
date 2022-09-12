import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/contact.dart';
import 'package:sudonym/config/config.dart';
import 'package:sudonym/data/repository/crud_repository.dart';
import 'package:sudonym/data/repository/websocket.dart';

import '../../injection.dart';

@Injectable(as: ContactRepository, env: Env.allButMock)
class ContactRepositoryImpl extends ContactRepository {
  ContactRepositoryImpl(Config config, Dio dio, Websocket websocket)
      : super(config, dio, websocket);
}

abstract class ContactRepository extends CrudRepository<Contact>
    with ContactRepositoryProps {
  ContactRepository(Config config, Dio dio, Websocket websocket)
      : super(config, dio, websocket);
}

class ContactRepositoryProps {
  @override
  String endpoint = "contact";
  @override
  Function converter = (e) => Contact.fromJson(e);
}
