import 'package:flutter/material.dart' hide Action, ButtonBar;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:sudonym/config/logger.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym.models/index.dart';

class AmountPage<T extends ActionTypeWithAmount> extends StatefulWidget
    with AmountLogger {
  final CurrencyInputOptions options;
  final String? text;
  final Future<void> Function(CurrencyInputOutput) onDone;

  const AmountPage(
      {required this.options, required this.onDone, this.text, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AmountPageState();
  }
}

class _AmountPageState extends State<AmountPage> with AmountLogger {
  late FormGroup formGroup;
  bool loading = false;

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
                                text: widget.text ??
                                    AppLocalizations.of(context)!.confirm,
                                icon: loading
                                    ? SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator())
                                    : null,
                                onPressed: formGroup.valid && !loading
                                    ? () async {
                                        setState(() {
                                          loading = true;
                                        });
                                        await widget.onDone(
                                            widget.options.controller!.value);
                                        setState(() {
                                          loading = false;
                                        });
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
