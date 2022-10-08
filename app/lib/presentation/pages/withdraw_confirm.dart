import 'package:flutter/material.dart' hide Action, ButtonBar;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/logic/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sudonym/presentation/index.dart';

import 'package:sudonym/injection.dart';

final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

class WithdrawConfirm extends StatelessWidget {
  final Withdraw action;
  const WithdrawConfirm(this.action, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) {
            return getIt<WithdrawCubit>()..getInfo(action);
          })
        ],
        child: BlocListener<WithdrawCubit, WithdrawCubitState>(
            listener: (context, state) {
          if (state.receiverData != null &&
              !state.loadingWithdraw &&
              state.receiverData!.isRight()) {
            state.receiverData!.fold((l) => null, (r) {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => ReceiverPage(r)),
                  ModalRoute.withName('/'));
            });
          }
        }, child: BlocBuilder<WithdrawCubit, WithdrawCubitState>(
                builder: (BuildContext context, state) {
          String pageTitle = '';
          String title = (AppLocalizations.of(context)!.withdrawInfo);
          String subtitle =
              (AppLocalizations.of(context)!.gatheringWithdrawInfomation);
          IconData? icon;
          Widget? content = const Center(
              child: CircularProgressIndicator(color: Colors.white));
          Color color = Colors.indigo.shade800;
          Widget? actions;

          if (state.loadingWithdraw) {
            title = 'Withdrawing';
            subtitle = 'Withdrawal is in progress';
            icon;
            content = const Center(
                child: CircularProgressIndicator(color: Colors.white));
            color = Colors.indigo.shade800;
            actions = null;
          }
          if (state.receiverData != null) {
            state.receiverData!.fold((l) {
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
                  (AppLocalizations.of(context)!.gatheredWithdrawalInformation);
              content = Column(children: [
                Table(
                  children: [],
                )
              ]);
              actions = ButtonBar(children: [
                ElevatedButton.icon(
                  label: Text(AppLocalizations.of(context)!.send),
                  icon:
                      const FaIcon(FontAwesomeIcons.paperPlane, size: iconSize),
                  onPressed: state.loadingInfo || state.loadingWithdraw
                      ? null
                      : () {
                          BlocProvider.of<WithdrawCubit>(context).withdraw(r);
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
