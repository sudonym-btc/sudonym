import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sudonym/config/index.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym.models/index.dart';

class TransactionList extends StatefulWidget {
  final Pot pot;
  const TransactionList({required this.pot, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => TransactionListState();
}

class TransactionListState extends State<TransactionList>
    with ListLogger, WidgetsBindingObserver {
  late ListCubit list;
  @override
  void initState() {
    super.initState();

    list = ListCubit(getIt<TransactionRepository>(),
        where: {'potId': widget.pot.id});
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (getIt<CurrentPotService>().pot?.id == widget.pot.id) {
        loggy.d('Changed app state registered in transaction list');
        list.loadPrevious();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.all(padding * 2),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GestureDetector(
              onTap: () => list.loadPrevious(),
              child: Subheader(AppLocalizations.of(context)!.transactions)),
          const VertDivider(),
          Expanded(
              child: ListWidget(
            builder: (el) {
              return CubitWrapper<TransactionCubit, TransactionCubitState,
                      Transaction>(
                  entity: el,
                  fetch: false,
                  refreshOnFocus: ((state) => state.entity?.status == null),
                  builder: (context, state) {
                    if (state.loading) {
                      return Container();
                    }
                    return TransactionListItem(
                      entity: state.entity!,
                      pot: widget.pot,
                    );
                  });
            },
            list: () => list,
            emptyText: (AppLocalizations.of(context)!.noTransactionsFound),
          ))
        ]));
  }
}
