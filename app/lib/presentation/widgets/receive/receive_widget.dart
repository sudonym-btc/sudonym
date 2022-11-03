import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart' hide ButtonBar;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/logic/index.dart';
// import 'package:share_plus/share_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rxdart/rxdart.dart';

class ReceiveWidget extends StatefulWidget {
  final Pot pot;
  final String type;
  const ReceiveWidget({required this.pot, required this.type, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => ReceiveWidgetState();
}

class ReceiveWidgetState extends State<ReceiveWidget> {
  late CurrencyInputOptions inputOptions;

  @override
  void initState() {
    inputOptions = CurrencyInputOptions(
        initialValue: CurrencyInputOutput(0, widget.pot.currency),
        currencies: [
          widget.pot.currency,
          widget.pot.currency == 'BTC' ? 'USD' : 'BTC'
        ]);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) {
            ReceiverCubit c = getIt<ReceiverCubit>();

            inputOptions.controller!.outputStream.stream
                .debounceTime(const Duration(milliseconds: 500))
                .listen((event) {
              c.getInvoice(
                  widget.pot.id, widget.type, event.amount, event.currency);
            });

            return c;
          })
        ],
        child: BlocBuilder<ReceiverCubit, ReceiverCubitState>(
            builder: (BuildContext context, state) {
          Widget image = const Center(child: CircularProgressIndicator());
          if (!state.loading && state.entity?.data != null) {
            image = QrImage(
              data: state.entity!.data,
              foregroundColor:
                  Theme.of(context).appBarTheme.titleTextStyle!.color,
              version: QrVersions.auto,
            );
          }
          return Column(
            children: [
              Expanded(
                  child: Stack(children: [
                image,
              ])),
              const SizedBox(height: padding),
              Padding(
                  padding: const EdgeInsets.all(padding),
                  child: CurrencyInput(options: inputOptions)),
              Padding(
                  padding: const EdgeInsets.all(padding),
                  child: ButtonBar(children: [
                    Button(
                      icon: const FaIcon(FontAwesomeIcons.copy, size: iconSize),
                      onPressed: state.loading
                          ? null
                          : () {
                              FlutterClipboard.copy(state.entity!.data)
                                  .then((value) {
                                SnackBar snackBar = SnackBar(
                                  content: Text(AppLocalizations.of(context)!
                                      .copiedToClipboard),
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              });
                            },
                      text: (AppLocalizations.of(context)!.copy),
                    ),
                    Button(
                      icon:
                          const FaIcon(FontAwesomeIcons.share, size: iconSize),
                      onPressed: state.loading
                          ? null
                          : () {
                              // Share.share('ln234wkfdoinfrwiofjirew',
                              //     subject: 'Bitcoin invoice for \$5');
                            },
                      text: (AppLocalizations.of(context)!.share),
                    ),
                  ]))
            ],
          );
        }));
  }
}
