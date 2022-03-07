import 'package:flutter/material.dart';
import 'package:sudonym.models/transaction.dart' as Model;
import 'package:sudonym/constants.dart';
import 'package:timeago/timeago.dart' as timeago;

class Transaction extends StatelessWidget {
  Model.Transaction transaction;

  Transaction({required Model.Transaction this.transaction, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
        child: Row(
      children: [
        SizedBox(width: 50, child: Text(transaction.amount.toString())),
        Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Lightning Transaction",
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              '"Random Descriptions"',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        )),
        SizedBox(
            width: 50,
            child: Center(
                child: Text(timeago.format(transaction.createdAt,
                    locale: 'en_short')))),
      ],
    ));
  }
}
