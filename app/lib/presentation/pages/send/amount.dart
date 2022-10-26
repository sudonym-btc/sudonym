import 'package:flutter/material.dart' hide Action, ButtonBar;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/config/logger.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym/presentation/pages/withdraw_confirm.dart';

class AmountPage extends StatefulWidget with AmountLogger {
  final dynamic action;
  final Pot? pot;
  const AmountPage({required this.action, this.pot, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AmountPageState();
  }
}

class _AmountPageState extends State<AmountPage> with AmountLogger {
  late CurrencyInputOptions options;

  @override
  void initState() {
    List<String> currencies = [];
    currencies.addAll(widget.pot != null ? [widget.pot!.currency] : []);
    currencies.addAll(['USD', 'BTC']);
    options = CurrencyInputOptions(
        currencies: currencies,
        max: widget.action?.maxAmount,
        min: widget.action?.minAmount,
        initialValue: CurrencyInputOutput(
            widget.action?.minAmount, widget.action.currency));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CurrencyInput currencyInput = CurrencyInput(options: options);

    return Container(
        color: Theme.of(context).backgroundColor,
        child: SafeArea(
          child: Scaffold(
              appBar: AppBar(
                title: const Text('Amount'),
              ),
              body: Padding(
                  padding: const EdgeInsets.all(padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: padding),
                      currencyInput,
                      Expanded(child: Container()),
                      ButtonBar(children: [
                        Button(
                          text: 'Confirm',
                          icon: const FaIcon(FontAwesomeIcons.paperPlane,
                              size: 14),
                          onPressed: () {
                            widget.action.amount =
                                options.controller!.value.amount;
                            widget.action.currency =
                                options.controller!.value.currency;
                            if (widget.action is Payment) {
                              Navigator.pushNamed(context, '/confirmSend',
                                  arguments: widget.action);
                            }
                            if (widget.action is Withdraw) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          WithdrawConfirm(widget.action)));
                            }
                          },
                        )
                      ])
                    ],
                  ))),
        ));
  }
}
