import 'package:flutter/cupertino.dart';
import 'package:sudonym/logic/index.dart';

class AmountText extends StatefulWidget {
  final num amount;
  final String currency;
  final DateTime? date;

  const AmountText(
      {required this.amount, required this.currency, this.date, super.key});

  @override
  State<StatefulWidget> createState() {
    return AmountTextState();
  }
}

class AmountTextState extends State<AmountText> {
  @override
  Widget build(BuildContext context) {
    return Text(FormatCurrency().format(widget.currency, widget.amount));
  }
}
