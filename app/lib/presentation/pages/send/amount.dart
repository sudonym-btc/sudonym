import 'package:flutter/material.dart' hide Action, ButtonBar;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym.models/types/index.dart';
import 'package:sudonym/config/logger.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym/presentation/pages/withdraw_confirm.dart';

class AmountPage extends StatefulWidget with AmountLogger {
  final dynamic action;

  const AmountPage(this.action, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AmountPageState();
  }
}

class _AmountPageState extends State<AmountPage> with AmountLogger {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    num min = 0;
    num? max;
    num? value;

    ActionRemoteResponse remoteResponse = widget.action?.remoteResponse;
    if (remoteResponse != null) {
      max = (remoteResponse.data['maxSendable'] ??
              remoteResponse.data['maxWithdrawable']) /
          MSATOSHIS;

      min = (remoteResponse.data['minSendable'] ??
              remoteResponse.data['minWithdrawable']) /
          MSATOSHIS;

      value = remoteResponse.data['minSendable'] != null ? min : max;
    }

    CurrencyInput currencyInput = CurrencyInput(
        max: widget.action?.maxAmount,
        min: widget.action?.minAmount,
        initialValue: value,
        initialValueCurrency: 'BTC',
        onChanged: (val) {
          widget.action.amount = val.amount;
          widget.action.currency = val.currency;
        });

    return Container(
        color: Theme.of(context).colorScheme.background,
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
