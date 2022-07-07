import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart' hide ButtonBar;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sudonym/presentation/components/button/button.dart';
import 'package:sudonym/presentation/widgets/input/button/button_bar.dart';
import 'package:sudonym/presentation/widgets/input/currency/currency_input.dart';
// import 'package:share_plus/share_plus.dart';

import '../../../constants.dart';
import '../../../injection.dart';
import '../../../logic/bloc/receive.cubit.dart';

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
              create: (_) =>
                  getIt<ReceiveCubit>()..getInvoice(potId, type, 1000))
        ],
        child: BlocBuilder<ReceiveCubit, ReceiveCubitState>(
            builder: (BuildContext context, state) {
          Widget image = Center(child: const CircularProgressIndicator());
          if (!state.loading) {
            image = QrImage(
              data: state.data!.get("data"),
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
              SizedBox(height: padding),
              Padding(
                padding: EdgeInsets.all(padding),
                child: CurrencyInput(onChanged: (amount) {
                  BlocProvider.of<ReceiveCubit>(context)
                    ..getInvoice(potId, type, amount);
                }),
              ),
              Padding(
                  padding: EdgeInsets.all(padding),
                  child: ButtonBar(children: [
                    Button(
                        icon: FaIcon(FontAwesomeIcons.copy, size: iconSize),
                        onPressed: state.loading
                            ? null
                            : () {
                                FlutterClipboard.copy(state.data!.get("data"))
                                    .then((value) {
                                  final snackBar = SnackBar(
                                    content: Text('Copied to Clipboard'),
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                });
                              },
                        text: "Copy"),
                    Button(
                        icon: FaIcon(FontAwesomeIcons.share, size: iconSize),
                        onPressed: state.loading
                            ? null
                            : () {
                                // Share.share('ln234wkfdoinfrwiofjirew',
                                //     subject: 'Bitcoin invoice for \$5');
                              },
                        text: "Share"),
                  ]))
            ],
          );
        }));
  }
}
