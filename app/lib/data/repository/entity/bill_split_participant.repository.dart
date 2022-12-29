import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym/config/index.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym.models/index.dart';

@LazySingleton(as: BillSplitParticipantRepository, env: Env.allButMock)
class BillSplitParticipantRepositoryImpl
    extends BillSplitParticipantRepository {
  BillSplitParticipantRepositoryImpl(
      Config config, Dio dio, Websocket websocket)
      : super(config, dio, websocket);
}

abstract class BillSplitParticipantRepository
    extends CrudRepository<BillSplitParticipant>
    with BillSplitParticipantRepositoryProps {
  BillSplitParticipantRepository(Config config, Dio dio, Websocket websocket)
      : super(config, dio, websocket);
}

class BillSplitParticipantRepositoryProps {
  String get endpoint => 'billSplitParticipant';
  BillSplitParticipant Function(Map<String, dynamic>) converter =
      (e) => BillSplitParticipant.fromJson(e);
}
