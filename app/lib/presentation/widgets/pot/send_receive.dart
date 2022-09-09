import 'package:flutter/material.dart' hide ButtonBar;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sudonym.models/pot.dart';
import 'package:sudonym/logic/bloc/receive.cubit.dart';
import 'package:sudonym/presentation/components/button/button.dart';
import 'package:sudonym/presentation/pages/receive.dart';
import 'package:sudonym/presentation/pages/send.dart';
import 'package:sudonym/presentation/widgets/input/button/button_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../injection.dart';

class SendReceive extends StatelessWidget {
  final Pot entity;
  const SendReceive({required this.entity, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [BlocProvider(create: (_) => getIt<ReceiveCubit>())],
        child: BlocBuilder<ReceiveCubit, ReceiveCubitState>(
            builder: (BuildContext context, state) {
          return LayoutBuilder(builder: (context, constraints) {
            // Widget image = state.loading
            //     ? CircularProgressIndicator()
            //     : QrImage(
            //         data: state.data!.data,
            //         version: QrVersions.auto,
            //         // embeddedImage: NetworkImage(
            //         //     'https://www.kindpng.com/picc/m/73-733879_lightning-bolt-emoji-png-electricity-emoji-transparent-png.png'),
            //         embeddedImageStyle: QrEmbeddedImageStyle(
            //           size: Size(40, 40),
            //         ),
            //       );

            // print(constraints);

            return Center(
                child: FractionallySizedBox(
                    widthFactor: 0.7,
                    // padding: const EdgeInsets.all(padding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment
                          .center, //Center Column contents vertically,
                      crossAxisAlignment: CrossAxisAlignment
                          .center, //Center Column contents horizontally,
                      children: [
                        ButtonBar(
                          children: [
                            Button(
                              text: AppLocalizations.of(context)!.receive,
                              icon: const FaIcon(FontAwesomeIcons.inbox,
                                  size: 14),
                              onPressed: () {
                                Navigator.pushNamed(context, '/receive',
                                    arguments:
                                        ReceivePageArgs(entity.get("id")));
                              },
                            ),
                            Button(
                              text: AppLocalizations.of(context)!.send,
                              icon: const FaIcon(FontAwesomeIcons.paperPlane,
                                  size: 14),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SendPage(
                                              potId: entity.get("id"),
                                            )));
                              },
                            )
                          ],
                        ),
                      ],
                    )));
          });
        }));
  }
}
