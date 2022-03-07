import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudonym/constants.dart';
import 'package:sudonym/data/repository/transaction.repository.dart';
import 'package:sudonym/logic/bloc/list/list.cubit.dart';
import 'package:sudonym/logic/bloc/transactions.cubit.dart';
import 'package:sudonym/presentation/widgets/list/list.dart';
import 'package:sudonym/presentation/widgets/transactions/transaction.dart';

import '../../../injection.dart';

class Transactions extends StatelessWidget {
  const Transactions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ListCubit<Transaction> list = new ListCubit(getIt<TransactionRepository>());
    list.loadNext();
    
    return Container(
        constraints: BoxConstraints.expand(),
        padding: EdgeInsets.all(padding * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(
            "Transactions",
            style: Theme.of(context).textTheme.headline4,
          ),
          SizedBox(height: padding,),
          Expanded(
              child: List(
            builder: (el) {
              return Transaction(transaction: el);
            },
            list: list,
            emptyText: 'No transactions found',
          ))
        ]));
  }
}
