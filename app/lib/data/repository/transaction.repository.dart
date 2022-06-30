import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/transaction.dart';
import 'package:sudonym/config/config.dart';
import 'package:sudonym/data/repository/crud_repository.dart';
import 'package:sudonym/data/repository/websocket.dart';

import '../../injection.dart';

@Injectable(as: TransactionRepository, env: Env.allButMock)
class TransactionRepositoryImpl extends TransactionRepository {
  @override
  Function converter = Transaction.fromJson;

  TransactionRepositoryImpl(Config config, Dio dio, Websocket websocket)
      : super(config, dio, websocket);
}

abstract class TransactionRepository extends crud_repository<Transaction> {
  @override
  String get endpoint => "transaction";

  TransactionRepository(Config config, Dio dio, Websocket websocket)
      : super(config, dio, websocket);
}
