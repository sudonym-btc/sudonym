import 'package:flutter/material.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/constants.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:timeago/timeago.dart' as timeago;

class TransactionListItem extends StatelessWidget {
  final Transaction entity;

  const TransactionListItem({required this.entity, Key? key}) : super(key: key);

  getTitle() {
    String networkName =
        ['lnurl', 'bolt11', 'bolt12', 'lightningaddress'].contains(entity.type)
            ? 'lightning network'
            : 'onchain';
    return entity.outgoing
        ? entity.address ?? 'Spent via $networkName'
        : 'Received $networkName';
  }

  getDescription() {
    return entity.description ?? 'No description';
  }

  @override
  Widget build(BuildContext context) {
    return CubitWrapper<TransactionCubit, Transaction>(
        entity: entity,
        fetch: false,
        builder: (context, TransactionCubitState state) {
          if (state.loading) {
            return Container();
          }
          return InkWell(
              onTap: () {
                Navigator.of(context)
                    .pushNamed('/transaction', arguments: entity);
              },
              child: Opacity(
                  opacity: state.entity!.status == true ? 1 : 0.6,
                  child: Container(
                      padding: const EdgeInsets.all(padding),
                      child: Row(
                        children: [
                          SizedBox(
                              width: 75,
                              child: Text(
                                (state.entity!.outgoing ? '- ' : '') +
                                    FormatCurrency().format(
                                        state.entity!.currencyCode,
                                        state.entity!.amount.toDouble()),
                                style: TextStyle(
                                    fontSize: 12,
                                    color: state.entity!.outgoing
                                        ? Theme.of(context).errorColor
                                        : Theme.of(context).primaryColor),
                              )),
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                getTitle(),
                                style: const TextStyle(
                                    overflow: TextOverflow.ellipsis),
                              ),
                              Info(getDescription()),
                            ],
                          )),
                          SizedBox(
                              width: 50,
                              child: Center(
                                  child: Info(timeago.format(entity.createdAt,
                                      locale: 'en_short')))),
                        ],
                      ))));
        });
  }
}
