import 'package:flutter/material.dart' hide Action, ButtonBar;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sudonym/config/logger.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym.models/index.dart';

class AmountPage<T extends ActionTypeWithAmount> extends StatefulWidget
    with AmountLogger {
  final T action;
  final Pot? pot;
  final void Function(T) onDone;

  const AmountPage(
      {required this.action, this.pot, required this.onDone, Key? key})
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
        max: widget.action.maxAmount,
        min: widget.action.minAmount,
        initialValue: CurrencyInputOutput(
            widget.action.minAmount ?? 0, widget.action.currency));
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
                title: Text(AppLocalizations.of(context)!.amount),
              ),
              body: (Padding(
                  padding: const EdgeInsets.all(padding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(child: Center(child: currencyInput)),
                      ButtonBar(children: [
                        Button(
                          text: AppLocalizations.of(context)!.confirm,
                          icon: const FaIcon(FontAwesomeIcons.paperPlane,
                              size: 14),
                          onPressed: () {
                            widget.action.amount =
                                options.controller!.value.amount;
                            widget.action.currency =
                                options.controller!.value.currency;
                            widget.onDone(widget.action);
                          },
                        )
                      ])
                    ],
                  )))),
        ));
  }
}
