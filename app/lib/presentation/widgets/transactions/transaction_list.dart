import 'package:flutter/material.dart';
import 'package:sudonym/constants.dart';
import 'package:sudonym/data/repository/transaction.repository.dart';
import 'package:sudonym/logic/bloc/list/list.cubit.dart';
import 'package:sudonym/logic/bloc/transactions.cubit.dart';
import 'package:sudonym/presentation/components/typography/header.dart';
import 'package:sudonym/presentation/widgets/list/list.dart';
import 'package:sudonym/presentation/widgets/transactions/transaction_list_item.dart';

import '../../../injection.dart';

class TransactionList extends StatelessWidget {
  const TransactionList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: BoxConstraints.expand(),
        padding: EdgeInsets.all(padding * 2),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Header("Transactions"),
          const SizedBox(
            height: padding,
          ),
          Expanded(
              child: List(
            builder: (el) {
              return Transaction(transaction: el);
            },
            list: ListCubit(getIt<TransactionRepository>()),
            emptyText: 'No transactions found',
          ))
        ]));
  }
}
