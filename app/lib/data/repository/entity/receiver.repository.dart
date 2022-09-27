import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/config/config.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';

@LazySingleton(as: ReceiverRepository, env: Env.allButMock)
class ReceiverRepositoryImpl extends ReceiverRepository {
  ReceiverRepositoryImpl(Config config, Dio dio, Websocket websocket)
      : super(config, dio, websocket);

  @override
  Future<Receiver> getInvoice(potId, type, amount, currency) {
    return dio.get('/receive/invoice', queryParameters: {
      'potId': potId.toString(),
      'type': type.toString(),
      'amount': amount.toString(),
      'amountCurrency': currency.toString()
    }).then((value) => Receiver.fromJson(value.data));
  }
}

abstract class ReceiverRepository extends CrudRepository<Receiver>
    with ReceiverRepositoryProps {
  ReceiverRepository(Config config, Dio dio, Websocket websocket)
      : super(config, dio, websocket);
  List<Receiver> receivers = [];

  Future<Receiver> getInvoice(potId, type, amount, currency);
}

class ReceiverRepositoryProps {
  @override
  String get endpoint => "receiver";
  @override
  Function converter = (e) => Receiver.fromJson(e);
}
