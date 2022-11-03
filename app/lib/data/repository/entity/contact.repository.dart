import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym/config/index.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym.models/index.dart';

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
  String endpoint = 'contact';
  Function converter = (e) => Contact.fromJson(e);
}
