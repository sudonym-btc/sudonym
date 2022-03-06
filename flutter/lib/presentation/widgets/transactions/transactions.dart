import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudonym/data/repository/transaction.repository.dart';
import 'package:sudonym/logic/bloc/transactions.cubit.dart';

import '../../../injection.dart';

class Transactions extends StatelessWidget {
  const Transactions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [BlocProvider(create: (_) => TransactionsCubit(getIt<TransactionRepository>(), TransactionsState()))],
        child: BlocBuilder<TransactionsCubit, TransactionsState>(
          builder: (context, state) {
            return Column(children: [
              Text(
                "Transactions",
                style: Theme.of(context).textTheme.headline3,
              ),
              // ListView()
            ]);
          },
        ));
  }
}
