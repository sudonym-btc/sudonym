import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym.models/index.dart';

class BoltCardList extends StatelessWidget {
  const BoltCardList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Header(AppLocalizations.of(context)!.boltCards),
            Button(
                text: AppLocalizations.of(context)!.addCard,
                onPressed: () => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditBoltCard(
                                  entity: BoltCard.fromJson({'name': ''}))))
                    })
          ]),
          const VertDivider(),
          Info(AppLocalizations.of(context)!.boltCardDescription),
          const VertDivider(),
          ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListWidget(
                  builder: (el) {
                    return BoltCardListItem(entity: el);
                  },
                  emptyText: AppLocalizations.of(context)!.noBoltCardsFound,
                  list: () {
                    return ListCubit(getIt<BoltCardRepository>());
                  }))
        ]);
  }
}
