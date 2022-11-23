import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym.models/index.dart';

class PotHeader extends StatelessWidget {
  final Pot entity;
  final Function? onMoveRight;
  final Function? onMoveLeft;
  const PotHeader({
    required this.entity,
    this.onMoveRight,
    this.onMoveLeft,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PotListReorganizerCubit, PotListState>(
        builder: ((context, state) {
      return Row(children: [
        Expanded(
            child: Padding(
                padding: EdgeInsets.only(top: padding, bottom: padding * 2),
                child: Slidable(
                    // Specify a key if the Slidable is dismissible.
                    key: const ValueKey(0),

                    // The start action pane is the one at the left or the top side.
                    startActionPane:
                        BlocProvider.of<PotListReorganizerCubit>(context)
                                .canMoveLeft(entity)
                            ? ActionPane(
                                // A motion is a widget used to control how the pane animates.
                                motion: const ScrollMotion(),

                                // A pane can dismiss the Slidable.
                                // dismissible: DismissiblePane(onDismissed: () {}),

                                // All actions are defined in the children parameter.
                                children: [
                                  // A SlidableAction can have an icon and/or a label.
                                  SlidableAction(
                                    onPressed: (BuildContext context) async {
                                      BlocProvider.of<PotListReorganizerCubit>(
                                              context)
                                          .onMoveLeft(entity);
                                    },
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    foregroundColor: Colors.white,
                                    icon: Icons.arrow_left,
                                    label: 'Move left',
                                  ),
                                ],
                              )
                            : null,
                    endActionPane:
                        BlocProvider.of<PotListReorganizerCubit>(context)
                                .canMoveRight(entity)
                            ? ActionPane(
                                // A motion is a widget used to control how the pane animates.
                                motion: const ScrollMotion(),

                                // A pane can dismiss the Slidable.
                                // dismissible: DismissiblePane(onDismissed: () {}),

                                // All actions are defined in the children parameter.
                                children: [
                                  // A SlidableAction can have an icon and/or a label.
                                  SlidableAction(
                                    onPressed: (BuildContext context) async {
                                      BlocProvider.of<PotListReorganizerCubit>(
                                              context)
                                          .onMoveRight(entity);
                                    },
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    foregroundColor: Colors.white,
                                    icon: Icons.arrow_right,
                                    label: 'Move right',
                                  ),
                                ],
                              )
                            : null,

                    // The child of the Slidable is what the user sees when the
                    // component is not dragged.
                    child: Row(children: [
                      Expanded(
                          child: InkWell(
                              onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          EditPot(entity: entity))),
                              child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: padding * 2, right: padding * 2),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Subtitle(entity.name ?? ''),
                                        Header(FormatCurrency().format(
                                            entity.currency, entity.balance)),
                                        entity.currency == 'BTC'
                                            ? AmountText(
                                                amount: entity.balance,
                                                fromCurrency: entity.currency,
                                                toCurrency: 'USD',
                                                builder: (val) =>
                                                    Info('≈ $val'),
                                              )
                                            : Container()
                                      ]))))
                    ]))))
      ]);
    }));
  }
}
