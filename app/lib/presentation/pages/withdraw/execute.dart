import 'package:flutter/material.dart' hide Action, ButtonBar;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym/presentation/pages/action/action_flow.dart';
import 'package:sudonym.models/index.dart';

class WithdrawExecutePage extends ActionFlow<Withdraw, Receiver> {
  final Withdraw action;
  const WithdrawExecutePage(
      {super.key,
      required super.onDone,
      required super.onError,
      required this.action});

  StatusPage errorPage(BuildContext context, Object err) {
    return StatusPage(
      color: Colors.red,
      title: AppLocalizations.of(context)!.failed,
      subtitleText: 'Could not create receiver for this withdrawal',
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
      ),
    );
  }

  StatusPage donePage(BuildContext context, action) {
    return loadingPage(context);
  }

  StatusPage loadingPage(BuildContext context) {
    return StatusPage(
      color: Colors.indigo.shade800,
      title: 'Withdrawing',
      subtitleText: 'Withdrawal in progress',
      content: loader,
    );
  }

  @override
  Widget build(BuildContext context) {
    return TaskBuilder(
        future: () => WithdrawManager().execute(action).then((data) {
              data.fold((l) => onError(l), (r) => onDone(r));
              return data;
            }),
        onSuccess: donePage,
        onError: errorPage);
  }
}
