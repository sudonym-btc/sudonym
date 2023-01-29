import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym.models/index.dart';

class PotHeader extends StatefulWidget {
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
  State<StatefulWidget> createState() => PotHeaderState();
}

class PotHeaderState extends State<PotHeader> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PotListReorganizerCubit, PotListState>(
        builder: ((context, state) {
      return Row(children: [
        Expanded(
            child: CustomPadding(
                multiplierWidth: 0,
                child: Slidable(
                    key: const ValueKey(0),
                    startActionPane: BlocProvider.of<PotListReorganizerCubit>(
                                context)
                            .canMoveLeft(widget.entity)
                        ? ActionPane(
                            motion: const ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (BuildContext context) async {
                                  BlocProvider.of<PotListReorganizerCubit>(
                                          context)
                                      .onMoveLeft(widget.entity);
                                },
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                icon: Icons.arrow_left,
                                label: AppLocalizations.of(context)!.moveLeft,
                              ),
                            ],
                          )
                        : null,
                    endActionPane: BlocProvider.of<PotListReorganizerCubit>(
                                context)
                            .canMoveRight(widget.entity)
                        ? ActionPane(
                            motion: const ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (BuildContext context) async {
                                  BlocProvider.of<PotListReorganizerCubit>(
                                          context)
                                      .onMoveRight(widget.entity);
                                },
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                icon: Icons.arrow_right,
                                label: AppLocalizations.of(context)!.moveRight,
                              ),
                            ],
                          )
                        : null,
                    child: Row(children: [
                      Expanded(
                          child: InkWell(
                              onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          EditPot(entity: widget.entity))),
                              child: CustomPadding(
                                  multiplierWidth: 2,
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Subtitle(
                                                  widget.entity.name ?? ''),
                                              Header(FormatCurrency().format(
                                                  widget.entity.currency,
                                                  widget.entity
                                                      .spendableBalance)),
                                              widget.entity.currency == 'BTC'
                                                  ? AmountText(
                                                      amount: widget.entity
                                                          .spendableBalance,
                                                      fromCurrency: widget
                                                          .entity.currency,
                                                      toCurrency: 'USD',
                                                      builder: (val) =>
                                                          Info('≈ $val'),
                                                    )
                                                  : Container()
                                            ]),
                                        // IconButton(
                                        //     iconSize: iconSize,
                                        //     color: Colors.grey,
                                        //     onPressed: () {},
                                        //     icon: FaIcon(FontAwesomeIcons.pen))
                                      ]))))
                    ]))))
      ]);
    }));
  }
}
