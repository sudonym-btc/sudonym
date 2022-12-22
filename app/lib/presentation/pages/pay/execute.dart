import 'package:flutter/material.dart' hide ButtonBar;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym/presentation/pages/action/action_flow.dart';
import 'package:sudonym.models/index.dart';

class PayExecutePage extends ActionFlow<Payment, Transaction> {
  final Payment action;
  const PayExecutePage(
      {super.key,
      required super.onDone,
      required super.onError,
      required this.action});

  @override
  Widget build(BuildContext context) {
    return TaskBuilder(
        future: () => PayManager().execute(action).then((data) {
              data.fold((l) => onError(l), (r) => onDone(r));
              return data;
            }),
        onError: errorPage);
  }

  StatusPage errorPage(BuildContext context, Object err) {
    return StatusPage(
        color: Colors.red,
        title: AppLocalizations.of(context)!.failed,
        subtitleText: AppLocalizations.of(context)!.failedToCreateTransactions,
        icon: FontAwesomeIcons.circleExclamation,
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
}
