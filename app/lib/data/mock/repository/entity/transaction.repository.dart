import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym/config/config.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym.models/transaction.dart';
import 'crud_repository.dart';

@LazySingleton(as: TransactionRepository, env: [Env.mock])
class MockTransactionRepository extends MockCrudRepository<Transaction>
    with TransactionRepositoryProps
    implements TransactionRepository {
  MockTransactionRepository(Config config, Dio dio, Websocket websocket)
      : super(config, dio, websocket);
}
