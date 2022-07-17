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
            .contains(transaction.get("type"))
        ? "lightning network"
        : "onchain";
    return transaction.get("outgoing")
        ? transaction.get("address") ?? "Spend via " + networkName
        : "Received " + networkName;
  }

  getDescription() {
    return transaction.get("description") ?? "No description";
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          Navigator.of(context)
              .pushNamed('/transaction', arguments: transaction);
        },
        child: Opacity(
            opacity: transaction.get("status") == true ? 1 : 0.6,
            child: Container(
                padding: EdgeInsets.all(padding),
                child: Row(
                  children: [
                    SizedBox(
                        width: 75,
                        child: Text(
                          (transaction.get("outgoing") ? "-" : "") +
                              FormatCurrency().format(
                                  transaction.get("currencyCode"),
                                  transaction.get("amount").toDouble()),
                          style: TextStyle(
                              fontSize: 12,
                              color: transaction.get("outgoing")
                                  ? Theme.of(context).errorColor
                                  : Theme.of(context).primaryColorDark),
                        )),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getTitle(),
                          style:
                              const TextStyle(overflow: TextOverflow.ellipsis),
                        ),
                        Info(getDescription()),
                      ],
                    )),
                    SizedBox(
                        width: 50,
                        child: Center(
                            child: Info(timeago.format(
                                transaction.get("createdAt").runtimeType ==
                                        DateTime
                                    ? transaction.get("createdAt")
                                    : DateTime.parse(
                                        transaction.get("createdAt")),
                                locale: 'en_short')))),
                  ],
                ))));
  }
}
