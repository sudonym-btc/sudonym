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
        color: Colors.red,
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
      color: Colors.indigo.shade800,
      title: 'Withdrawing',
      subtitleText: AppLocalizations.of(context)!.gatheredWithdrawalInformation,
      content: Column(children: [
        Table(
          children: [
            TableRow(children: [
              Text(AppLocalizations.of(context)!.amount),
              Text(FormatCurrency()
                  .format(action.currency ?? 'BTC', action.amount ?? 0))
            ]),
            TableRow(children: [
              Text(AppLocalizations.of(context)!.address),
              Text(
                action.originalAddress,
                style: const TextStyle(
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ]),
          ],
        )
      ]),
    );
  }

  StatusPage loadingPage(BuildContext context) {
    return StatusPage(
      color: Colors.indigo.shade800,
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
