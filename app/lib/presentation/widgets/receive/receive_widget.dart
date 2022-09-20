import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart' hide ButtonBar;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sudonym.models/types/currency.dart';
import 'package:sudonym/constants.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/components/button/button.dart';
import 'package:sudonym/presentation/widgets/input/button/button_bar.dart';
import 'package:sudonym/presentation/widgets/input/currency/currency_input.dart';
// import 'package:share_plus/share_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ReceiveWidget extends StatelessWidget {
  final num potId;
  final String type;
  const ReceiveWidget({required this.potId, required this.type, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (_) => getIt<ReceiverCubit>()
                ..getInvoice(potId, type, 1 / SATOSHIS, 'BTC'))
        ],
        child: BlocBuilder<ReceiverCubit, ReceiverCubitState>(
            builder: (BuildContext context, state) {
          Widget image = const Center(child: CircularProgressIndicator());
          if (!state.loading) {
            image = QrImage(
              data: state.entity!.data,
              version: QrVersions.auto,
              // embeddedImage: AssetImage('assets/images/my_embedded_image.png'),
              // embeddedImageStyle: QrEmbeddedImageStyle(
              //   size: Size(80, 80),
              // ),
            );
          }
          return Column(
            children: [
              Expanded(child: image),
              const SizedBox(height: padding),
              Padding(
                padding: const EdgeInsets.all(padding),
                child: CurrencyInput(onChanged: (amount) {
                  BlocProvider.of<ReceiverCubit>(context)
                      .getInvoice(potId, type, amount.amount, amount.currency);
                }),
              ),
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
                                const snackBar = SnackBar(
                                  content: Text('Copied to Clipboard'),
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
