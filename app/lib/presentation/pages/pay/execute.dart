import 'package:flutter/material.dart' hide ButtonBar;
import 'package:sudonym.models/index.dart';
import 'package:sudonym/logic/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sudonym/presentation/index.dart';

import 'package:sudonym/presentation/pages/action/action_flow.dart';

class PayExecutePage extends ActionFlow<Payment> {
  final Payment action;
  const PayExecutePage(
      {super.key, required super.onDone, required this.action});

  @override
  Widget build(BuildContext context) {
    return TaskBuilder(
        future: () => PayManager().execute(action), onError: errorPage);
  }

  StatusPage errorPage(BuildContext context, Object err) {
    return StatusPage(
        color: Colors.red,
        title: AppLocalizations.of(context)!.failed,
        subtitle: AppLocalizations.of(context)!.failedToCreateTransactions,
        icon: FontAwesomeIcons.circleExclamation,
        content: Text(err.toString()),
        actions: ButtonBar(
          children: [
            ElevatedButton(
              style: raisedButtonStyle,
              onPressed: () {},
              child: Text(AppLocalizations.of(context)!.retry),
            )
          ],
        ));
  }
}
