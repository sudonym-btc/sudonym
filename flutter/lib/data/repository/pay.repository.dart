import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/transaction-confirm.dart';
import 'package:sudonym.models/transaction.dart';

import '../../injection.dart';

@prod
@Injectable(as: PayRepository, env: [Env.prod])
class PayRepositoryImpl extends PayRepository {
  PayRepositoryImpl(Dio dio) : super(dio);

  @override
  Future<TransactionConfirm> getInfo(address) {
    return dio
        .get('/pay/info?address=' + address)
        .then((value) => TransactionConfirm.fromJson(value.data));
  }

  @override
  Future<Transaction> pay(address) {
    return dio
        .get('/pay/info')
        .then((value) => Transaction.fromJson(value.data));
  }
}

abstract class PayRepository {
  Dio dio;
  Future<TransactionConfirm> getInfo(address);
  Future<Transaction> pay(address);
  PayRepository(this.dio);
}
