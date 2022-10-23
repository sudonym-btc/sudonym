import 'package:flutter/material.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:timeago/timeago.dart' as timeago;

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
                child: Row(
                  children: [
                    SizedBox(
                        width: 75,
                        child: AmountText(
                            fromCurrency: entity.currencyCode,
                            toCurrency: pot?.currency ?? entity.currencyCode,
                            amount: entity.amount,
                            date: entity.createdAt,
                            builder: (state) => Text(state,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: entity.outgoing
                                        ? Theme.of(context).errorColor
                                        : Theme.of(context).primaryColor)))),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getTitle(entity),
                          style:
                              const TextStyle(overflow: TextOverflow.ellipsis),
                        ),
                        Info(getDescription(entity)),
                      ],
                    )),
                    SizedBox(
                        width: 50,
                        child: Center(
                            child: Info(timeago.format(entity.createdAt,
                                locale: 'en_short')))),
                  ],
                ))));
  }
}

getTitle(Transaction entity) {
  String networkName =
      ['lnurl', 'bolt11', 'bolt12', 'lightningaddress'].contains(entity.type)
          ? 'via lightning network'
          : 'onchain';
  return entity.outgoing ? 'Spent $networkName' : 'Received $networkName';
}

getDescription(Transaction entity) {
  return entity.description ?? 'No description';
}
