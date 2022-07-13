import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/index.dart';

import '../../injection.dart';

@LazySingleton(as: PayRepository, env: Env.allButMock)
class PayRepositoryImpl extends PayRepository {
  PayRepositoryImpl(Dio dio) : super(dio);

  @override
  Future<AddressParseResponse> parse(String p) {
    return dio
        .get('/pay/parse?address=' + p)
        .then((value) => AddressParseResponse(value.data));
  }

  @override
  Future<Payment> getInfo(Payment p) {
    return dio.post('/pay/info',
        data: {"payment": p}).then((value) => Payment(value.data));
  }

  @override
  Future<Transaction> pay(Payment p) {
    return dio.post('/pay',
        data: {'payment': p}).then((value) => Transaction(value.data));
  }
}

abstract class PayRepository {
  Dio dio;
  Future<Payment> getInfo(Payment p);
  Future<Transaction> pay(Payment p);
  Future<dynamic> parse(String addr);
  PayRepository(this.dio);
}
