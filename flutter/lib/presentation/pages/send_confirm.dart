import 'package:flutter/material.dart' hide ButtonBar;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sudonym/data/repository/pay.repository.dart';
import 'package:sudonym/logic/bloc/send.cubit.dart';
import 'package:sudonym/presentation/widgets/input/button/button_bar.dart';
import 'package:sudonym/presentation/widgets/send/qr.dart';

import '../../constants.dart';
import '../../injection.dart';

final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

class SendConfirmPage extends StatelessWidget {
  const SendConfirmPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Object? data = ModalRoute.of(context)?.settings.arguments;

    return Container(
        color: Theme.of(context).colorScheme.background,
        child: SafeArea(
            child: Scaffold(
                appBar: AppBar(
                  title: const Text('Send'),
                ),
                body: Padding(
                    padding: EdgeInsets.all(padding),
                    child: MultiBlocProvider(
                        providers: [
                          BlocProvider(
                              create: (_) =>
                                  getIt<SendCubit>()..getInfo(data.toString()))
                        ],
                        child: BlocBuilder<SendCubit, SendCubitState>(
                            builder: (BuildContext context, state) {
                          if (state.completed) {
                            return _CompletedWidget();
                          } else if (state.loadingSend) {
                            return _SendingWidget();
                          } else if (state.loadingInfo) {
                            return Center(
                                child: const CircularProgressIndicator());
                          }

                          if (state.transactionData != null) {
                            state.transactionData!
                                .fold((l) => Text(l.toString()), (r) => Text('success'));
                          } else if (state.infoData != null) {
                            state.infoData!
                                .fold((l) => Text(l.toString()), (r) => Text('success'));
                          }

                          return Column(
                            children: [
                              Expanded(child: Container()),
                              ButtonBar(children: [
                                ElevatedButton.icon(
                                  label: Text('Confirm'),
                                  style: raisedButtonStyle,
                                  icon: FaIcon(FontAwesomeIcons.paperPlane,
                                      size: iconSize),
                                  onPressed: state.loadingInfo ||
                                          state.loadingSend
                                      ? null
                                      : () {
                                          BlocProvider.of<SendCubit>(context)
                                              .pay("");
                                        },
                                )
                              ])
                            ],
                          );
                        }))))));
  }
}

class _CompletedWidget extends StatelessWidget {
  static const IconData check = IconData(0xe156, fontFamily: 'MaterialIcons');

  @override
  Widget build(BuildContext context) {
    return Center(child: FaIcon(FontAwesomeIcons.checkCircle));
  }
}

class _SendingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: FaIcon(FontAwesomeIcons.plane));
  }
}
