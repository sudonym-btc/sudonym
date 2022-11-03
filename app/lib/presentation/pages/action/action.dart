import 'package:flutter/material.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym/presentation/pages/action/action_flow.dart';
import 'package:sudonym.models/index.dart';

class ActionPage extends StatelessWidget {
  final String address;
  final void Function(ActionParseResponse) onDone;
  final Function onError;

  const ActionPage(
      {required this.address,
      required this.onDone,
      required this.onError,
      Key? key})
      : super(key: key);

  StatusPage loadingPage(BuildContext context, dynamic succ) {
    return StatusPage(content: loader, color: Colors.indigo.shade800);
  }

  StatusPage errorPage(BuildContext context, dynamic err) {
    // Error came from remote service
    if (err.response?.statusCode == 503) {
      return StatusPage(
          title: 'Error',
          subtitle: 'Could not get OK response from remote server',
          content: Text(err.message.toString()),
          color: Theme.of(context).errorColor);
    }
    return StatusPage(
        title: 'Error',
        subtitle: 'Encountered an unrecoverable error',
        content: Text(err.toString()),
        color: Theme.of(context).errorColor);
  }

  needsAmount(ActionParseResponse parse) {
    return parse.payment != null
        ? PayManager.canChangeAmount(parse.payment)
        : WithdrawManager.canChangeAmount(parse.withdraw);
  }

  @override
  Widget build(BuildContext context) {
    return TaskBuilder(
      future: () {
        return ActionLoader(address).parse().then((value) {
          value.fold((l) => onError(l), ((r) => onDone(r)));
          return value;
        });
      },
      onSuccess: loadingPage,
      onError: errorPage,
    );
  }
}
