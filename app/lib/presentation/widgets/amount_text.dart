import 'package:flutter/cupertino.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/logic/index.dart';

class AmountText extends StatefulWidget {
  final num amount;
  final String fromCurrency;
  final String toCurrency;
  final DateTime? date;
  final Widget Function(String val)? builder;

  const AmountText(
      {required this.amount,
      required this.fromCurrency,
      required this.toCurrency,
      this.date,
      this.builder,
      super.key});

  @override
  State<StatefulWidget> createState() {
    return AmountTextState();
  }
}

class AmountTextState extends State<AmountText> {
  String val = '';
  @override
  void initState() {
    val = FormatCurrency().format(widget.fromCurrency, widget.amount);
    getIt<CurrencyRepository>()
        .getRate(
            fromCurrency: widget.fromCurrency,
            toCurrency: widget.toCurrency,
            amount: widget.amount,
            time: widget.date)
        .then((value) => setState(() =>
            {val = FormatCurrency().format(widget.toCurrency, value.amount)}));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder != null ? widget.builder!(val) : Text(val);
  }
}
