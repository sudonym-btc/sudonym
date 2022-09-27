import 'package:flutter/material.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:sudonym/injection.dart';

class BoltCardList extends StatelessWidget {
  const BoltCardList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Subheader(AppLocalizations.of(context)!.boltCards),
          const SizedBox(
            height: padding,
          ),
          Expanded(
              child: ListWidget(
                  builder: (el) {
                    return BoltCardListItem(entity: el);
                  },
                  list: ListCubit(getIt<BoltCardRepository>()),
                  appendItem: Button(
                      text: 'Add Card',
                      onPressed: () => {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EditBoltCard(
                                        entity:
                                            BoltCard.fromJson({'name': ''}))))
                          })))
        ]);
  }
}
