import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudonym/data/repository/transaction.repository.dart';

class TransactionsCubit extends Cubit<TransactionsState> {
  final TransactionRepository _transactionRepository;

  TransactionsCubit(this._transactionRepository, initialState) : super(initialState);
}

class TransactionsState {}
