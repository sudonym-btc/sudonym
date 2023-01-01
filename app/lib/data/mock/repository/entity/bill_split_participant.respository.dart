import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym/config/index.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym.models/index.dart';

@LazySingleton(as: BillSplitParticipantRepository, env: [Env.mock])
class MockBillSplitParticipantRepository
    extends MockCrudRepository<BillSplitParticipant>
    with BillSplitParticipantRepositoryProps
    implements BillSplitParticipantRepository {
  MockBillSplitParticipantRepository(
      Config config, Dio dio, Websocket websocket)
      : super(config, dio, websocket);
}
