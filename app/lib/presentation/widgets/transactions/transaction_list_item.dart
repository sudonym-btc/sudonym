import 'package:flutter/material.dart';
import 'package:sudonym.models/transaction.dart';
import 'package:sudonym/constants.dart';
import 'package:sudonym/logic/currency/format-currency.dart';
import 'package:sudonym/presentation/components/typography/info.dart';
import 'package:timeago/timeago.dart' as timeago;

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;

  const TransactionListItem({required this.transaction, Key? key})
      : super(key: key);

  getTitle() {
    String networkName = ["lnurl", "bolt11", "bolt12", "lightningaddress"]
            .contains(transaction.type)
        ? "lightning network"
        : "onchain";
    return transaction.outgoing
        ? transaction.address ?? "Spend via " + networkName
        : "Received " + networkName;
  }

  getDescription() {
    return transaction.description ?? "No description";
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          Navigator.of(context).pushNamed('/transaction');
        },
        child: Container(
            padding: EdgeInsets.all(padding),
            child: Row(
              children: [
                SizedBox(
                    width: 75,
                    child: Text(
                      (transaction.outgoing ? "-" : "") +
                          FormatCurrency().format(transaction.currencyCode,
                              transaction.amount.toDouble()),
                      style: TextStyle(
                          fontSize: 12,
                          color: transaction.outgoing
                              ? Theme.of(context).errorColor
                              : Theme.of(context).primaryColorDark),
                    )),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(getTitle()),
                    Info(getDescription()),
                  ],
                )),
                SizedBox(
                    width: 50,
                    child: Center(
                        child: Info(timeago.format(transaction.createdAt,
                            locale: 'en_short')))),
              ],
            )));
  }
}
