import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym/data/repository/transaction.repository.dart';
import 'package:sudonym/injection.dart';

import 'crud_repository.dart';
import 'package:sudonym.models/transaction.dart';

@dev
@Injectable(as: TransactionRepository, env: [Env.dev])
class MockTransactionRepository extends crud_repository<Transaction> implements TransactionRepository {
  MockTransactionRepository(Dio dio) : super(dio);

  @override
  String get endpoint => "transaction";
}
