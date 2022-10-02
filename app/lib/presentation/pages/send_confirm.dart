import 'package:flutter/material.dart' hide Action, ButtonBar;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/logic/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sudonym/presentation/index.dart';

import 'package:sudonym/injection.dart';

final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

class SendConfirmPage extends StatelessWidget {
  const SendConfirmPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var payment = ModalRoute.of(context)?.settings.arguments as Payment;

    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) {
            return getIt<SendCubit>()..getInfo(payment);
          })
        ],
        child: BlocListener<SendCubit, SendCubitState>(
            listener: (context, state) {
          if (state.transactionData != null &&
              !state.loadingSend &&
              state.transactionData!.isRight()) {
            state.transactionData!.fold((l) => null, (r) {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/transaction', ModalRoute.withName('/'),
                  arguments: r);
            });
          }
        }, child: BlocBuilder<SendCubit, SendCubitState>(
                builder: (BuildContext context, state) {
          String pageTitle = '';
          String title = (AppLocalizations.of(context)!.paymentInfo);
          String subtitle =
              (AppLocalizations.of(context)!.gatheringPaymentInfomation);
          IconData? icon;
          Widget? content = const Center(
              child: CircularProgressIndicator(color: Colors.white));
          Color color = Colors.indigo.shade800;
          Widget? actions;

          if (state.loadingSend) {
            title = 'Sending';
            subtitle = 'Payment is in progress';
            icon;
            content = const Center(
                child: CircularProgressIndicator(color: Colors.white));
            color = Colors.indigo.shade800;
            actions = null;
          }
          if (state.transactionData != null) {
            state.transactionData!.fold((l) {
              color = Colors.red;
              title = (AppLocalizations.of(context)!.failed);
              subtitle =
                  (AppLocalizations.of(context)!.failedToCreateTransactions);
              icon = FontAwesomeIcons.circleExclamation;
              content = Text(l.toString());
              actions = ButtonBar(
                children: [
                  ElevatedButton(
                    style: raisedButtonStyle,
                    onPressed: () {},
                    child: Text(AppLocalizations.of(context)!.retry),
                  )
                ],
              );
            }, (r) {});
          } else if (state.infoData != null) {
            state.infoData?.fold((l) {
              color = Colors.red;
              title = 'Error';
              content = Text(l.toString());
              actions = ButtonBar(
                children: [
                  ElevatedButton(
                    style: raisedButtonStyle,
                    onPressed: () {},
                    child: Text(AppLocalizations.of(context)!.retry),
                  )
                ],
              );
            }, (r) {
              subtitle =
                  (AppLocalizations.of(context)!.gatheredPaymentInformation);
              content = Column(children: [
                Table(
                  children: [
                    TableRow(children: [
                      Text(AppLocalizations.of(context)!.amount),
                      Text(FormatCurrency()
                          .format(r.currency ?? 'BTC', r.amount ?? 0))
                    ]),
                    TableRow(children: [
                      Text(AppLocalizations.of(context)!.fee),
                      Text(FormatCurrency()
                          .format(r.feeCurrency ?? 'BTC', r.fee ?? 0))
                    ]),
                    TableRow(children: [
                      const Text('address'),
                      Text(
                        r.address ?? '',
                        style: const TextStyle(
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    ]),
                    TableRow(children: [
                      Text(AppLocalizations.of(context)!.name),
                      Text(
                        r.originalAddress,
                        style: const TextStyle(
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    ]),
                  ],
                )
              ]);
              actions = ButtonBar(children: [
                ElevatedButton.icon(
                  label: Text(AppLocalizations.of(context)!.send),
                  icon:
                      const FaIcon(FontAwesomeIcons.paperPlane, size: iconSize),
                  onPressed: state.loadingInfo || state.loadingSend
                      ? null
                      : () {
                          BlocProvider.of<SendCubit>(context).pay(r);
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
