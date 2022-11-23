import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym.models/index.dart';

class PotHeader extends StatelessWidget {
  final Pot entity;
  const PotHeader({
    required this.entity,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
        // Specify a key if the Slidable is dismissible.
        key: const ValueKey(0),

        // The start action pane is the one at the left or the top side.
        startActionPane: ActionPane(
          // A motion is a widget used to control how the pane animates.
          motion: const ScrollMotion(),

          // A pane can dismiss the Slidable.
          // dismissible: DismissiblePane(onDismissed: () {}),

          // All actions are defined in the children parameter.
          children: entity.PotUsers[0].index > 1
              ? [
                  // A SlidableAction can have an icon and/or a label.
                  SlidableAction(
                    onPressed: (BuildContext context) async {
                      getIt<PotUserRepository>().update({
                        ...entity.PotUsers[0].toJson(),
                        'index': entity.PotUsers[0].index--
                      });
                    },
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    icon: Icons.arrow_left,
                    label: 'Move left',
                  ),
                ]
              : [],
        ),
        endActionPane: ActionPane(
          // A motion is a widget used to control how the pane animates.
          motion: const ScrollMotion(),

          // A pane can dismiss the Slidable.
          // dismissible: DismissiblePane(onDismissed: () {}),

          // All actions are defined in the children parameter.
          children: [
            // A SlidableAction can have an icon and/or a label.
            SlidableAction(
              onPressed: (BuildContext context) async {
                getIt<PotUserRepository>().update({
                  ...entity.PotUsers[0].toJson(),
                  'index': entity.PotUsers[0].index++
                });
              },
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              icon: Icons.arrow_right,
              label: 'Move right',
            ),
          ],
        ),

        // The child of the Slidable is what the user sees when the
        // component is not dragged.
        child: Padding(
            padding: const EdgeInsets.all(padding * 2),
            child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => EditPot(entity: entity)));
                },
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Subtitle(entity.name ?? ''),
                      Header(FormatCurrency()
                          .format(entity.currency, entity.balance)),
                      entity.currency == 'BTC'
                          ? AmountText(
                              amount: entity.balance,
                              fromCurrency: entity.currency,
                              toCurrency: 'USD',
                              builder: (val) => Info('≈ $val'),
                            )
                          : Container()
                    ]))));
  }
}
