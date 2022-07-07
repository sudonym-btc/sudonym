import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/index.dart';

import '../../injection.dart';

@LazySingleton(as: ReceiveRepository, env: Env.allButMock)
class ReceiveRepositoryImpl extends ReceiveRepository {
  ReceiveRepositoryImpl(Dio dio) : super(dio);

  @override
  Future<Receiver> getInvoice(potId, type, amount) {
    return dio.get('/receive/invoice', queryParameters: {
      "potId": potId.toString(),
      "type": type.toString(),
      "amount": amount.toString()
    }).then((value) => Receiver(value.data));
  }
}

abstract class ReceiveRepository {
  List<Receiver> receivers = [];
  Dio dio;
  Future<Receiver> getInvoice(potId, type, amount);

  ReceiveRepository(this.dio);
}
