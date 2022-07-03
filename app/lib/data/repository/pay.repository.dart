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
        .then((value) => AddressParseResponse.fromJson(value.data));
  }

  @override
  Future<Payment> getInfo(Payment p) {
    return dio
        .get('/pay/info?address=' + p.originalAddress)
        .then((value) => Payment.fromJson(value.data));
  }

  @override
  Future<Transaction> pay(Payment p) {
    return dio.post('/pay', data: {'address': p.originalAddress}).then(
        (value) => Transaction.fromJson(value.data));
  }
}

abstract class PayRepository {
  Dio dio;
  Future<Payment> getInfo(Payment p);
  Future<Transaction> pay(Payment p);
  Future<dynamic> parse(String addr);
  PayRepository(this.dio);
}
