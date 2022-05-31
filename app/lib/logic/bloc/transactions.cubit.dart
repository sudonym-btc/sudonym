import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym/data/repository/transaction.repository.dart';

@injectable
class TransactionsCubit extends Cubit<TransactionsState> {
  final TransactionRepository _transactionRepository;

  TransactionsCubit(this._transactionRepository) : super(TransactionsState());
}

class TransactionsState {}
