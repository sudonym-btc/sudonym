import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/contact.dart';
import 'package:sudonym/config/config.dart';
import 'package:sudonym/data/repository/websocket.dart';
import 'package:sudonym/injection.dart';

import 'crud_repository.dart';

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
  String endpoint = 'contact';
  @override
  Function converter = (e) => Contact.fromJson(e);
}
