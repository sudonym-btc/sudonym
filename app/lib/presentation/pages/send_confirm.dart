import 'dart:collection';

import 'package:flutter/material.dart' hide ButtonBar;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sudonym/data/repository/pay.repository.dart';
import 'package:sudonym/logic/bloc/send.cubit.dart';
import 'package:sudonym/presentation/widgets/input/button/button_bar.dart';

import '../../constants.dart';
import '../../injection.dart';
import '../widgets/status_page/status_page.dart';

final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

class SendConfirmPage extends StatelessWidget {
  const SendConfirmPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dynamic data = ModalRoute.of(context)?.settings.arguments;

    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) {
            // print(data);
            return getIt<SendCubit>()..getInfo(data['address'].toString());
          })
        ],
        child: BlocListener<SendCubit, SendCubitState>(
            listener: (context, state) {
          if (state.transactionData != null) {
            Navigator.pushReplacementNamed(context, '/transaction');
          }
        }, child: BlocBuilder<SendCubit, SendCubitState>(
                builder: (BuildContext context, state) {
          String pageTitle = '';
          String title = 'Payment Info';
          String subtitle = 'Gathering payment information';
          IconData? icon;
          Widget? content =
              Center(child: CircularProgressIndicator(color: Colors.white));
          Color color = Colors.indigo.shade800;
          Widget? actions = null;

          if (state.transactionData != null) {
            state.transactionData!.fold((l) {
              color = Colors.red;
              title = 'Failed';
              subtitle = 'Failed to create transaction';
              icon = FontAwesomeIcons.exclamationCircle;
              content = null;
              actions = ButtonBar(
                children: [
                  ElevatedButton(
                    child: Text('Retry'),
                    style: raisedButtonStyle,
                    onPressed: () {},
                  )
                ],
              );
            }, (r) {});
          } else if (state.loadingSend) {
            title = 'Sending';
            subtitle = 'Payment is in progress';
            icon;
            content =
                Center(child: CircularProgressIndicator(color: Colors.white));
            color = Colors.indigo.shade800;
            actions = null;
          } else if (state.infoData != null) {
            state.infoData?.fold((l) {
              color = Colors.red;
              subtitle = '';
              actions = ButtonBar(
                children: [
                  ElevatedButton(
                    child: Text('Retry'),
                    style: raisedButtonStyle,
                    onPressed: () {},
                  )
                ],
              );
            }, (r) {
              subtitle = 'Gathered payment information';
              content = Column(children: [
                Table(
                  children: [
                    TableRow(children: [
                      new Text('address'),
                      new Text(
                        r.address,
                        style: TextStyle(
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    ]),
                    TableRow(children: [
                      new Text('fee'),
                      new Text(r.feeMSat.toString() + ' sats / \$0.01')
                    ]),
                    TableRow(children: [new Text('name'), new Text(r.name)])
                  ],
                )
              ]);
              actions = ButtonBar(children: [
                ElevatedButton.icon(
                  label: Text('Send'),
                  icon: FaIcon(FontAwesomeIcons.paperPlane, size: iconSize),
                  onPressed: state.loadingInfo || state.loadingSend
                      ? null
                      : () {
                          BlocProvider.of<SendCubit>(context).pay(r.address);
                        },
                  style: raisedButtonStyle,
                )
              ]);
            });
          }

          return StatusPage(
            pageTitle: pageTitle,
            title: title,
            subtitle: subtitle,
            content: content,
            actions: actions,
            color: color,
          );
        })));
  }
}
