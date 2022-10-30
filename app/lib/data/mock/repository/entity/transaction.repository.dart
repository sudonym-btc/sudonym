import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym/config/index.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym.models/index.dart';

@LazySingleton(as: TransactionRepository, env: [Env.mock])
class MockTransactionRepository extends MockCrudRepository<Transaction>
    with TransactionRepositoryProps
    implements TransactionRepository {
  MockTransactionRepository(Config config, Dio dio, Websocket websocket)
      : super(config, dio, websocket);
}
