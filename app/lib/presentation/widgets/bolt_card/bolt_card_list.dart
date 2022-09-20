import 'package:flutter/material.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/constants.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/logic/bloc/list/list.cubit.dart';
import 'package:sudonym/presentation/components/button/button.dart';
import 'package:sudonym/presentation/components/typography/header.dart';
import 'package:sudonym/presentation/pages/bolt_card/edit_bolt_card.dart';
import 'package:sudonym/presentation/widgets/list/list.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../injection.dart';
import 'bolt_card_list_item.dart';

class BoltCardList extends StatelessWidget {
  const BoltCardList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Header(AppLocalizations.of(context)!.boltCards),
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
