import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/index.dart';

import '../../injection.dart';

@prod
@Injectable(as: ReceiveRepository, env: [Env.prod])
class ReceiveRepositoryImpl extends ReceiveRepository {
  ReceiveRepositoryImpl(Dio dio) : super(dio);

  @override
  Future<Receiver> getInvoice(potId, type, amount) {
    return dio
        .get('/receive/info?amount=' + amount)
        .then((value) => Receiver.fromJson(value.data));
  }
}

abstract class ReceiveRepository {
  Dio dio;
  Future<Receiver> getInvoice(potId, type, amount);

  ReceiveRepository(this.dio);
}
