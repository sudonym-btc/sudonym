import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym/config/config.dart';
import 'package:sudonym/data/repository/transaction.repository.dart';
import 'package:sudonym/injection.dart';

import '../../repository/websocket.dart';
import 'crud_repository.dart';
import 'package:sudonym.models/transaction.dart';

@LazySingleton(as: TransactionRepository, env: [Env.mock])
class MockTransactionRepository extends crud_repository<Transaction>
    implements TransactionRepository {
  @override
  String get endpoint => "transaction";

  MockTransactionRepository(Config config, Dio dio, Websocket websocket)
      : super(config, dio, websocket);
}
