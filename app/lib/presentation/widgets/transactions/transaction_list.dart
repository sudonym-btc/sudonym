import 'package:flutter/material.dart';
import 'package:sudonym.models/pot.dart';
import 'package:sudonym/constants.dart';
import 'package:sudonym/data/repository/transaction.repository.dart';
import 'package:sudonym/logic/bloc/list/list.cubit.dart';
import 'package:sudonym/presentation/components/typography/header.dart';
import 'package:sudonym/presentation/widgets/list/list.dart';
import 'package:sudonym/presentation/widgets/transactions/transaction_list_item.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../injection.dart';

class TransactionList extends StatelessWidget {
  final Pot pot;
  const TransactionList({required this.pot, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: const BoxConstraints.expand(),
        padding: const EdgeInsets.all(padding * 2),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Header(AppLocalizations.of(context)!.transactions),
          const SizedBox(
            height: padding,
          ),
          Expanded(
              child: List(
            builder: (el) {
              return TransactionListItem(transaction: el);
            },
            list: ListCubit(getIt<TransactionRepository>(),
                where: {"potId": pot.get("id")}),
            emptyText: (AppLocalizations.of(context)!.noTransactionsFound),
          ))
        ]));
  }
}
