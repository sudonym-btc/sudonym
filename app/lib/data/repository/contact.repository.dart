import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/contact.dart';
import 'package:sudonym/data/repository/crud_repository.dart';
import 'package:sudonym/data/repository/websocket.dart';

import '../../injection.dart';

@Injectable(as: ContactRepository, env: Env.allButMock)
class ContactRepositoryImpl extends ContactRepository {
  @override
  String get endpoint => "contact";

  @override
  Function converter = Contact.fromJson;

  ContactRepositoryImpl(Dio dio, Websocket websocket) : super(dio, websocket);

}

abstract class ContactRepository extends crud_repository<Contact> {
  ContactRepository(Dio dio, Websocket websocket) : super(dio, websocket);
}
