import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/data/mock/repository/crud_repository.dart';
import 'package:sudonym/data/repository/pay.repository.dart';

@dev
@Injectable(as: PayRepository, env: [Env.dev])
class MockPayRepository implements PayRepository {

  MockPayRepository(this.dio);

  @override
  getInfo(address) async {
    await Future.delayed(requestDelay);
    return TransactionConfirm(100);
  }

  @override
  pay(address) async {
    await Future.delayed(requestDelay);
    return Transaction("1", "1", "1", 10000, true, "1", "1", DateTime(2020));
  }

  @override
  Dio dio;
}
