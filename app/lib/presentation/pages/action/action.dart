import 'package:flutter/material.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym/presentation/pages/action/action_flow.dart';
import 'package:sudonym.models/index.dart';

class ActionPage extends ActionFlow<ActionType, ActionParseResponse> {
  final String address;

  const ActionPage(
      {required this.address,
      required super.onDone,
      required super.onError,
      Key? key})
      : super(key: key);

  StatusPage loadingPage(BuildContext context, dynamic succ) {
    return StatusPage(content: loader, color: Colors.indigo.shade800);
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
