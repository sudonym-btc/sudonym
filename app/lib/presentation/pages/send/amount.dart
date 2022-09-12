import 'package:flutter/material.dart' hide Action, ButtonBar;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/config/logger.dart';
import 'package:sudonym/presentation/components/button/button.dart';
import 'package:sudonym/presentation/widgets/input/button/button_bar.dart';
import 'package:sudonym/presentation/widgets/input/currency/currency_input.dart';

import '../../../constants.dart';

class AmountPage extends StatefulWidget with AmountLogger {
  final dynamic payment;

  const AmountPage(this.payment, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AmountPageState();
  }
}

class _AmountPageState extends State<AmountPage> with AmountLogger {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    CurrencyInput currencyInput = CurrencyInput(onChanged: (val) {
      widget.payment.amount = val.amount;
      widget.payment.currency = val.currency;
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
                            Navigator.pushNamed(context, '/confirmSend',
                                arguments: widget.payment);
                          },
                        )
                      ])
                    ],
                  ))),
        ));
  }
}
