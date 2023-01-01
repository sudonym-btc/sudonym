import 'package:flutter/material.dart' hide ButtonBar;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym.models/index.dart';

class SendReceive extends StatelessWidget {
  final Pot entity;
  const SendReceive({required this.entity, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [BlocProvider(create: (_) => getIt<ReceiverCubit>())],
        child: BlocBuilder<ReceiverCubit, ReceiverCubitState>(
            builder: (BuildContext context, state) {
          return LayoutBuilder(builder: (buildContext, constraints) {
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
                                  size: iconSize),
                              onPressed: () {
                                Navigator.pushNamed(context, '/receive',
                                    arguments: ReceiveOptions(pot: entity));
                              },
                            ),
                            Button(
                              text: AppLocalizations.of(context)!.send,
                              icon: const FaIcon(FontAwesomeIcons.paperPlane,
                                  size: iconSize),
                              onPressed: () {
                                Navigator.push(
                                    buildContext,
                                    MaterialPageRoute(
                                        builder: (context) => SendPage(
                                              pot: BlocProvider.of<PotCubit>(
                                                      buildContext)
                                                  .state
                                                  .entity!,
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
