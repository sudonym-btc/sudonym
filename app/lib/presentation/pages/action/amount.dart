import 'package:flutter/material.dart' hide Action, ButtonBar;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:sudonym/config/logger.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym.models/index.dart';

class AmountPage<T extends ActionTypeWithAmount> extends StatefulWidget
    with AmountLogger {
  final CurrencyInputOptions options;
  final void Function(CurrencyInputOutput) onDone;

  const AmountPage({required this.options, required this.onDone, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AmountPageState();
  }
}

class _AmountPageState extends State<AmountPage> with AmountLogger {
  late FormGroup formGroup;

  @override
  void initState() {
    formGroup = FormGroup({
      'amount': FormControl<CurrencyInputOutput>(
        value: widget.options.initialValue,
      ),
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant AmountPage<ActionTypeWithAmount> oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    CurrencyInput currencyInput = CurrencyInput(
      form: formGroup,
      options: widget.options,
      large: false,
    );

    return Container(
      color: Theme.of(context).backgroundColor,
      child: SafeArea(
          child: Scaffold(
              appBar: AppBar(
                title: Text(AppLocalizations.of(context)!.amount),
              ),
              body: CustomPadding(
                  multiplier: 2,
                  child: ReactiveForm(
                      formGroup: formGroup,
                      child: ReactiveFormConsumer(
                          builder: (context, formGroup, child) {
                        return Column(
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
                                onPressed: formGroup.valid
                                    ? () {
                                        widget.onDone(
                                            widget.options.controller!.value);
                                      }
                                    : null,
                              )
                            ])
                          ],
                        );
                      }))))),
    );
  }
}
