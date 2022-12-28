import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym/config/index.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym.models/index.dart';

@LazySingleton(as: BillSplitRepository, env: [Env.mock])
class MockBillSplitRepository extends MockCrudRepository<BillSplit>
    with BillSplitRepositoryProps
    implements BillSplitRepository {
  MockBillSplitRepository(Config config, Dio dio, Websocket websocket)
      : super(config, dio, websocket);
}
