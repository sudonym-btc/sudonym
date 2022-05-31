import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/transaction.dart';
import 'package:sudonym/data/repository/crud_repository.dart';
import 'package:sudonym/data/repository/websocket.dart';

import '../../injection.dart';

@Injectable(as: TransactionRepository, env: Env.allButMock)
class TransactionRepositoryImpl extends TransactionRepository {
  @override
  Function converter = Transaction.fromJson;

  TransactionRepositoryImpl(Dio dio, Websocket websocket)
      : super(dio, websocket);

}

abstract class TransactionRepository extends crud_repository<Transaction> {
  @override
  String get endpoint => "transaction";

  TransactionRepository(Dio dio, Websocket websocket) : super(dio, websocket);
}
