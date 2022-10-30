import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/config/index.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';

@LazySingleton(as: TransactionRepository, env: Env.allButMock)
class TransactionRepositoryImpl extends TransactionRepository {
  TransactionRepositoryImpl(Config config, Dio dio, Websocket websocket)
      : super(config, dio, websocket);
}

abstract class TransactionRepository extends CrudRepository<Transaction>
    with TransactionRepositoryProps {
  TransactionRepository(Config config, Dio dio, Websocket websocket)
      : super(config, dio, websocket);
}

class TransactionRepositoryProps {
  String get endpoint => 'transaction';
  Function converter = (e) => Transaction.fromJson(e);
}
