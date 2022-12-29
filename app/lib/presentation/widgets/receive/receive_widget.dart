import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart' hide ButtonBar;
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:share_plus/share_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym.models/index.dart';

const defaultPaymentTypes = ['lnurl', 'onchain', 'bolt11'];

class ReceiveOptions {
  List<String> types;
  Pot? pot;
  BillSplit? billSplit;
  BillSplitParticipant? participant;

  Function(Receiver t, BuildContext context)? onReceive;

  ReceiveOptions(
      {this.types = defaultPaymentTypes,
      this.pot,
      this.billSplit,
      this.participant,
      this.onReceive});
}

class ReceiveWidget extends StatefulWidget {
  final ReceiveOptions opts;
  final String type;
  const ReceiveWidget({required this.opts, required this.type, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => ReceiveWidgetState();
}

class ReceiveWidgetState extends State<ReceiveWidget> {
  late CurrencyInputOptions inputOptions;

// add the amount of the current widget to the withdraw actions triggered while on this page
  ActionParseResponse cb(ActionParseResponse a) {
    if (a.withdraw != null) {
      CurrencyInputOutput lastEvent = inputOptions.controller!.value;
      a.withdraw.currency = lastEvent.currency;
      a.withdraw.amount = lastEvent.amount;
      a.withdraw.minAmount = lastEvent.amount;
      a.withdraw.maxAmount = lastEvent.amount;
    }
    return a;
  }

  @override
  void initState() {
    super.initState();

    if (widget.opts.billSplit != null) {
      inputOptions = CurrencyInputOptions(
          initialValue: CurrencyInputOutput(0, widget.opts.billSplit!.currency),
          currencies: [widget.opts.billSplit!.currency, 'USD', 'BTC']);
    } else if (widget.opts.pot != null) {
      inputOptions = CurrencyInputOptions(
          initialValue: CurrencyInputOutput(0, widget.opts.pot!.currency),
          currencies: [widget.opts.pot!.currency, 'USD', 'BTC']);
    }
    getIt<ActionTriggerService>().callbacks.add(cb);
  }

  @override
  void dispose() {
    getIt<ActionTriggerService>().callbacks.remove(cb);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) {
            ReceiverCubit c = getIt<ReceiverCubit>();

            c.onReceived.stream.listen((event) {
              print(event);
              print('header');
              if (widget.opts.onReceive != null) {
                widget.opts.onReceive!(event, context);
              }
            });

            // If splitting bill, create a single receiver
            if (widget.opts.billSplit != null) {
              c.create(Receiver.fromJson({
                'potId': widget.opts.billSplit!.potId,
                'billSplitParticipantId': widget.opts.participant!.id,
                'amountCurrency': widget.opts.billSplit!.currency,
                'amount': widget.opts.participant!.amount,
                'type': widget.type,
              }));

              // If receiving in general, create new receiver every time amount changes
            } else {
              inputOptions.controller!.outputStream.stream
                  .debounceTime(const Duration(milliseconds: 500))
                  .listen((event) {
                c.create(Receiver.fromJson({
                  'potId': widget.opts.pot?.id ?? widget.opts.billSplit?.potId,
                  'amountCurrency': event.currency,
                  'amount': event.amount,
                  'type': widget.type,
                }));
              });
            }

            return c;
          })
        ],
        child: BlocBuilder<ReceiverCubit, ReceiverCubitState>(
            builder: (BuildContext context, state) {
          bool loading = state.loading || state.entity?.data == null;
          copy() {
            FocusScope.of(context).unfocus();

            FlutterClipboard.copy(state.entity!.data).then((value) {
              SnackBar snackBar = SnackBar(
                content: Text(AppLocalizations.of(context)!.copiedToClipboard),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            });
          }

          Widget image = Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Center(child: CircularProgressIndicator())]);

          if (!loading) {
            image = GestureDetector(
              onTap: copy,
              child: QrImage(
                  dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.circle),
                  eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.circle),
                  data: state.entity!.data,
                  foregroundColor:
                      Theme.of(context).appBarTheme.titleTextStyle!.color,
                  version: QrVersions.auto),
            );
          }
          var buttons = [
            Button(
              // icon: const FaIcon(FontAwesomeIcons.copy, size: iconSize),
              onPressed: loading ? null : copy,
              text: (AppLocalizations.of(context)!.copy),
            ),
            Button(
              // icon: const FaIcon(FontAwesomeIcons.share, size: iconSize),
              onPressed: loading
                  ? null
                  : () {
                      Share.share(state.entity!.data);
                    },
              text: (AppLocalizations.of(context)!.share),
            ),
          ];

          Widget type = Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Theme.of(context).primaryColor,
              ),
              child: CustomPadding(
                  multiplierHeight: 0.2,
                  child: Info(
                    widget.type.toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  )));

          Widget indicator = Opacity(
              opacity: 0.5,
              child: CustomPadding(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    Column(
                      children: [
                        type,
                        const VertDivider(),
                        Info(AppLocalizations.of(context)!.swipeForMoreOptions)
                      ],
                    ),
                  ])));

          return CustomPadding(
              child: Column(
            children: [
              Expanded(
                  child: Column(
                // mainAxisAlignment: loading ? MainAxisAlignment.center : null,
                children: [
                  ...(loading ? [] : [indicator]),
                  Expanded(child: image),
                ],
              )),
              const VertDivider(),
              if (widget.opts.billSplit == null)
                CustomPadding(
                    child: CurrencyInput(options: inputOptions, large: false)),
              CustomPadding(child: ButtonBar(children: buttons))
            ],
          ));
        }));
  }
}
