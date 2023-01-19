import 'package:flutter/material.dart' hide Action, ButtonBar;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym/presentation/pages/action/action_flow.dart';
import 'package:sudonym.models/index.dart';

class WithdrawInfoPage extends ActionFlow<Withdraw, Withdraw> {
  final Withdraw action;
  const WithdrawInfoPage(
      {super.key,
      required super.onDone,
      required super.onError,
      required this.action});

  StatusPage errorPage(BuildContext context, Object err) {
    return StatusPage(
        color: Theme.of(context).errorColor,
        title: AppLocalizations.of(context)!.failed,
        content: Text(err.toString()),
        actions: ButtonBar(
          children: [
            Button(
              onPressed: () {},
              text: AppLocalizations.of(context)!.retry,
            )
          ],
        ));
  }

  StatusPage donePage(BuildContext context, action) {
    return StatusPage(
        color: loadingColor,
        title: 'Withdrawing',
        subtitleText:
            AppLocalizations.of(context)!.gatheredWithdrawalInformation,
        content: Column(children: [
          Table(children: [
            getRow(
                Subtitle(AppLocalizations.of(context)!.amount),
                Text(FormatCurrency()
                    .format(action.currency ?? 'BTC', action.amount ?? 0))),
            getRow(
                Subtitle(AppLocalizations.of(context)!.address),
                Text(
                  action.originalAddress,
                  style: const TextStyle(
                    overflow: TextOverflow.ellipsis,
                  ),
                ))
          ]),
        ]));
  }

  StatusPage loadingPage(BuildContext context) {
    return StatusPage(
      color: loadingColor,
      title: AppLocalizations.of(context)!.withdrawInfo,
      subtitleText: AppLocalizations.of(context)!.gatheringWithdrawInfomation,
      content:
          const Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TaskBuilder(
        future: () => WithdrawManager().info(action).then((data) {
              data.fold((l) => onError(l), (r) => onDone(r));
              return data;
            }),
        onSuccess: donePage,
        onError: errorPage);
  }
}
