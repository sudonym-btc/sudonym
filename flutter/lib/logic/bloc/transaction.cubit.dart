import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/transaction.dart';

import '../../data/repository/transaction.repository.dart';
import 'entity_cubit_state.dart';

@injectable
class TransactionCubit extends EntityCubit<TransactionCubitState> {
  @override
  final TransactionRepository repository;

  TransactionCubit(this.repository) : super(TransactionCubitState(), TransactionCubitState.init);
}

class TransactionCubitState extends EntityCubitState<Transaction> {
  TransactionCubitState({Transaction? entity = null, bool loading = false})
      : super(entity: entity, loading: loading);

  TransactionCubitState.init({Transaction? entity = null, bool loading = false})
      : super(entity: entity, loading: loading);
}
