import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/transaction.dart';
import 'package:sudonym/config/config.dart';
import 'package:sudonym/data/repository/crud_repository.dart';
import 'package:sudonym/data/repository/websocket.dart';

import '../../injection.dart';

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
  @override
  String get endpoint => "transaction";
  @override
  Function converter = (e) => Transaction.fromJson(e);
}
