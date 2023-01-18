import 'package:dio/dio.dart';
import 'package:flutter/material.dart' hide ButtonBar;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym/presentation/pages/action/action_flow.dart';
import 'package:sudonym.models/index.dart';

class PayInfoPage extends ActionFlow<Payment, Payment> {
  final Payment action;
  final Pot pot;
  const PayInfoPage(
      {super.key,
      required super.onDone,
      required super.onError,
      required this.pot,
      required this.action});

  @override
  Widget build(BuildContext context) {
    return TaskBuilder(
      future: () {
        return PayManager().info(action);
      },
      onSuccess: donePage,
      onError: errorPage,
    );
  }

  Widget donePage(BuildContext context, r) {
    return _InfoPage(r, pot, onDone);
  }

  StatusPage errorPage(BuildContext context, Object err) {
    return StatusPage(
        color: Colors.red,
        title: AppLocalizations.of(context)!.failed,
        content: err is DioError
            ? Text(err.response.toString())
            : Text(err.toString()));
  }

  StatusPage loadingPage(BuildContext context) {
    return StatusPage(
        color: Colors.indigo.shade800,
        title: AppLocalizations.of(context)!.paymentInfo,
        subtitleText: AppLocalizations.of(context)!.gatheringPaymentInfomation,
        content: loader);
  }
}

class PaymentInfoPreview extends StatelessWidget {
  final Payment entity;
  final Pot? pot;
  const PaymentInfoPreview({required this.entity, this.pot, super.key});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Table(
        columnWidths: const {
          0: IntrinsicColumnWidth(),
          1: FlexColumnWidth(),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(children: [
            TableKey(child: Subtitle(AppLocalizations.of(context)!.amount)),
            AmountText(
                showLoader: false,
                amount: entity.amount,
                fromCurrency: entity.currency,
                toCurrency: pot?.currency ?? entity.currency,
                builder: (state) => Text(state))
          ]),
          TableRow(children: [
            TableKey(child: Subtitle(AppLocalizations.of(context)!.fee)),
            AmountText(
                showLoader: false,
                amount: entity.fee,
                fromCurrency: entity.feeCurrency,
                toCurrency: pot?.currency ?? entity.feeCurrency,
                builder: (state) => Text(state))
          ]),
          if (entity.originalAddress != entity.address)
            TableRow(children: [
              TableKey(child: Subtitle(AppLocalizations.of(context)!.address)),
              Text(
                entity.address ?? '',
                style: const TextStyle(
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ]),
          TableRow(children: [
            TableKey(child: Subtitle(AppLocalizations.of(context)!.to)),
            Text(
              entity.originalAddress,
              style: const TextStyle(
                overflow: TextOverflow.ellipsis,
              ),
            )
          ]),
          if (entity.description != null && entity.description != '')
            TableRow(children: [
              TableKey(
                  child: Subtitle(AppLocalizations.of(context)!.description)),
              Text(
                entity.description,
                style: const TextStyle(
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ]),
        ],
      )
    ]);
  }
}

class _InfoPage extends StatefulWidget {
  final Payment action;
  final Pot pot;
  final Function onDone;

  const _InfoPage(this.action, this.pot, this.onDone);

  @override
  State<StatefulWidget> createState() => _InfoPageState();
}

class _InfoPageState extends State<_InfoPage> {
  late FormGroup form;
  @override
  initState() {
    super.initState();
    form = FormGroup({
      'comment': FormControl<String>(validators: [
        Validators.maxLength(widget.action.commentAllowed ?? 256)
      ]),
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => CurrencyInputCubit(CurrencyInputOptions(
                max: [
                  CurrencyInputOutput(
                      widget.pot.spendableBalance, widget.pot.currency)
                ],
                min: [
                  CurrencyInputOutput(
                      widget.action.minAmount, widget.action.currency)
                ],
                initialValue: CurrencyInputOutput(
                    widget.action.amount, widget.action.currency))),
        child: BlocBuilder<CurrencyInputCubit, CurrencyInputCubitState>(
            builder: (context, state) {
          return ReactiveForm(
              formGroup: form,
              child: StatusPage(
                  color: Colors.indigo.shade800,
                  title: AppLocalizations.of(context)!.paymentInfo,
                  subtitleText:
                      AppLocalizations.of(context)!.gatheredPaymentInformation,
                  content: Column(children: [
                    PaymentInfoPreview(
                      entity: widget.action,
                      pot: widget.pot,
                    ),
                    ReactiveTextField(
                        formControlName: 'comment',
                        maxLines: 5,
                        minLines: 1,
                        decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.comment)),
                  ]),
                  actions: Column(children: [
                    if (state.error != null)
                      CustomPadding(
                          child: ErrorText(formatError(context, state.error))),
                    ButtonBar(children: [
                      if (state.error != null)
                        Button(
                          text: AppLocalizations.of(context)!.back,
                          onPressed: () => Navigator.of(context).pop(),
                        )
                      else if (state.maxLoading || state.minLoading)
                        const Button(
                          icon: SizedBox(
                            height: iconSize,
                            width: iconSize,
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else
                        ReactiveFormConsumer(
                            builder: ((context, formGroup, child) => Button(
                                  text: AppLocalizations.of(context)!.send,
                                  // icon: const FaIcon(FontAwesomeIcons.paperPlane,
                                  //     size: iconSize),
                                  onPressed: form.valid
                                      ? () {
                                          widget.action.comment =
                                              form.control('comment').value;
                                          widget.onDone(widget.action);
                                        }
                                      : null,
                                )))
                    ])
                  ])));
        }));
  }
}
