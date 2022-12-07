import 'package:flutter/material.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/logic/index.dart';

class AmountText extends StatefulWidget {
  final bool showLoader;
  final num amount;
  final String fromCurrency;
  final String toCurrency;
  final DateTime? date;
  final Widget Function(String val)? builder;

  const AmountText(
      {this.showLoader = true,
      required this.amount,
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
  bool loading = false;
  @override
  void initState() {
    val = FormatCurrency().format(widget.fromCurrency, widget.amount);
    load();
    super.initState();
  }

  @override
  didUpdateWidget(AmountText t) {
    super.didUpdateWidget(t);
    load();
  }

  load() {
    setState(() {
      loading = true;
    });
    getIt<CurrencyRepository>()
        .getRate(
            fromCurrency: widget.fromCurrency,
            toCurrency: widget.toCurrency,
            amount: widget.amount,
            time: widget.date)
        .then((value) => setState(() {
              val = FormatCurrency().format(widget.toCurrency, value.amount);
              loading = false;
            }));
  }

  @override
  Widget build(BuildContext context) {
    return loading && widget.showLoader
        ? const SizedBox(
            height: 12,
            width: 12,
            child: CircularProgressIndicator(
              strokeWidth: 1,
            ))
        : (widget.builder != null ? widget.builder!(val) : Text(val));
  }
}
