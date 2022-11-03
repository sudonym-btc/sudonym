import 'package:injectable/injectable.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym.models/index.dart';

@injectable
class TransactionCubit extends EntityCubit<TransactionRepository,
    TransactionCubitState, Transaction> {
  TransactionCubit()
      : super(
            initialState: TransactionCubitState(),
            stateClass: TransactionCubitState.init);
}

class TransactionCubitState extends EntityCubitState<Transaction> {
  TransactionCubitState({Transaction? entity, bool loading = false})
      : super(entity: entity, loading: loading);

  TransactionCubitState.init({Transaction? entity, bool loading = false})
      : this(entity: entity, loading: loading);
}
