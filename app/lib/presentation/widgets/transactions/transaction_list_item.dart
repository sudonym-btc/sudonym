import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym.models/index.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:timeago_flutter/timeago_flutter.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction entity;
  final Pot? pot;

  const TransactionListItem({required this.entity, this.pot, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          Navigator.of(context).pushNamed('/transaction', arguments: entity);
        },
        child: Opacity(
            opacity: entity.status == true ? 1 : 0.6,
            child: Container(
                padding: const EdgeInsets.all(padding),
                color: entity.status == false
                    ? Theme.of(context).errorColor.withAlpha(40)
                    : Colors.transparent,
                child: Row(
                  children: [
                    SizedBox(
                        width: 75,
                        child: Row(children: [
                          AmountText(
                              fromCurrency: entity.currencyCode,
                              toCurrency: pot?.currency ?? entity.currencyCode,
                              amount: entity.amount,
                              date: entity.createdAt,
                              builder: (state) => Text(state,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: entity.outgoing
                                          ? Theme.of(context).errorColor
                                          : Theme.of(context).primaryColor)))
                        ])),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getTitle(context, entity),
                          style:
                              const TextStyle(overflow: TextOverflow.ellipsis),
                        ),
                        Info(getDescription(context, entity)),
                      ],
                    )),
                    SizedBox(
                        width: 50,
                        child: Center(
                            child: Timeago(
                          builder: ((context, value) => Text(timeago.format(
                              entity.createdAt,
                              locale:
                                  Localizations.localeOf(context).toString() +
                                      '_short'))),
                          date: entity.createdAt,
                        ))),
                  ],
                ))));
  }
}

getTitle(BuildContext context, Transaction entity) {
  if (['lnurl', 'bolt11', 'bolt12', 'lightningaddress'].contains(entity.type)) {
    if (entity.outgoing) return AppLocalizations.of(context)!.spentViaLightning;
    return AppLocalizations.of(context)!.receivedViaLightning;
  } else if (entity.type == 'onchain') {
    if (entity.outgoing) return AppLocalizations.of(context)!.spentOnChain;
    return AppLocalizations.of(context)!.receivedOnChain;
  }

  return '';
}

getDescription(BuildContext context, Transaction entity) {
  return entity.description ?? AppLocalizations.of(context)!.noDescription;
}
