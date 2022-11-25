import 'package:injectable/injectable.dart';
import 'package:sudonym/config/index.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym.models/index.dart';

@lazySingleton
@injectable
class IncomingTransactionHandlerService with ActionLogger {
  late TransactionRepository _transactionRepository =
      getIt<TransactionRepository>();
  final CallbackHandler<Transaction> callbacks = CallbackHandler<Transaction>();

  IncomingTransactionHandlerService() {
    _transactionRepository.created.stream.listen((event) {
      callbacks.handle(event);
    });
  }
}
