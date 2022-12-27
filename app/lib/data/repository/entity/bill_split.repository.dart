import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym/config/index.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym.models/bill-split.dart';

@LazySingleton(as: BillSplitRepository, env: Env.allButMock)
class BillSplitRepositoryImpl extends BillSplitRepository {
  BillSplitRepositoryImpl(Config config, Dio dio, Websocket websocket)
      : super(config, dio, websocket);
}

abstract class BillSplitRepository extends CrudRepository<BillSplit>
    with BillSplitRepositoryProps {
  BillSplitRepository(Config config, Dio dio, Websocket websocket)
      : super(config, dio, websocket);
}

class BillSplitRepositoryProps {
  String get endpoint => 'billSplit';
  BillSplit Function(Map<String, dynamic>) converter =
      (e) => BillSplit.fromJson(e);
}
