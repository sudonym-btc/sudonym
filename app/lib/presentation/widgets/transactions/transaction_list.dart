import 'package:flutter/material.dart';
import 'package:sudonym.models/pot.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart' hide Pot;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:sudonym/injection.dart';

class TransactionList extends StatelessWidget {
  final Pot pot;
  const TransactionList({required this.pot, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        constraints: const BoxConstraints.expand(),
        padding: const EdgeInsets.all(padding * 2),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Header(AppLocalizations.of(context)!.transactions),
          const SizedBox(
            height: padding,
          ),
          Expanded(
              child: ListWidget(
            builder: (el) {
              return TransactionListItem(entity: el);
            },
            list: () {
              return ListCubit(getIt<TransactionRepository>(),
                  where: {'potId': pot.id});
            },
            emptyText: (AppLocalizations.of(context)!.noTransactionsFound),
          ))
        ]));
  }
}
