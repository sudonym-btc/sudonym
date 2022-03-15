import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/transaction.dart';
import 'package:sudonym.models/types/list.dart';
import 'package:sudonym/data/repository/crud_repository.dart';

import '../../injection.dart';

@prod
@Injectable(as: TransactionRepository, env: [Env.prod])
class TransactionRepositoryImpl extends TransactionRepository {
  TransactionRepositoryImpl(Dio dio) : super(dio);

  @override
  Future<Transaction> create() {
    // TODO: implement create
    throw UnimplementedError();
  }

  @override
  Future<ListState<Transaction>> list() {
    // TODO: implement list
    throw UnimplementedError();
  }

  @override
  Future<Transaction> update() {
    // TODO: implement update
    throw UnimplementedError();
  }

}

abstract class TransactionRepository extends crud_repository<Transaction> {
  TransactionRepository(Dio dio) : super(dio);
}