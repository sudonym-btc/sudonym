import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/index.dart';

import '../../injection.dart';

@LazySingleton(as: ActionRepository, env: Env.allButMock)
class ActionRepositoryImpl extends ActionRepository {
  ActionRepositoryImpl(Dio dio) : super(dio);

  @override
  Future<Action> parse(String address) {
    return dio
        .get('/action/parse?address=$address')
        .then((value) => Action(value.data));
  }

  @override
  Future<Action> getInfo(Action action) {
    return dio.post('/action/info',
        data: {"action": action}).then((value) => Action(value.data));
  }

  @override
  Future<Transaction> pay(Payment p) {
    return dio.post('/pay',
        data: {'action': p}).then((value) => Transaction(value.data));
  }

  @override
  Future<Action> withdraw(Withdraw w) {
    return dio.post('/withdraw',
        data: {'action': w}).then((value) => Action(value.data));
  }
}

abstract class ActionRepository {
  Dio dio;
  Future<Action> parse(String address);
  Future<Action> getInfo(Action action);
  Future<Transaction> pay(Payment p);
  Future<Action> withdraw(Withdraw w);
  ActionRepository(this.dio);
}
