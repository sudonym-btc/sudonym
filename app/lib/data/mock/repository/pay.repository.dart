import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/data/mock/repository/crud_repository.dart';
import 'package:sudonym/data/repository/pay.repository.dart';

@Injectable(as: PayRepository, env: [Env.mock])
class MockPayRepository implements PayRepository {
  MockPayRepository(this.dio);

  @override
  getInfo(address) async {
    await Future.delayed(requestDelay);
    return TransactionConfirm("MockReceiver", address, 10, 1000, 100);
  }

  @override
  pay(address) async {
    await Future.delayed(requestDelay);
    return Transaction("1", true, "lnurl", "lnurl4r4", "1", "1", 10000, true,
        true, "1", "1", DateTime(2020));
  }

  @override
  Dio dio;
}
