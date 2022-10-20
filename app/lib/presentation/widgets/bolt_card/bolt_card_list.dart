import 'package:flutter/material.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/logic/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:sudonym/injection.dart';

class BoltCardList extends StatelessWidget {
  const BoltCardList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Header(AppLocalizations.of(context)!.boltCards),
          const SizedBox(
            height: padding,
          ),
          const Info(
              'Write your account details to an NFC card so that you can tap them to a point of sales device to pay.'),
          const SizedBox(
            height: padding,
          ),
          ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListWidget(
                  builder: (el) {
                    return BoltCardListItem(entity: el);
                  },
                  list: () {
                    return ListCubit(getIt<BoltCardRepository>());
                  },
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
