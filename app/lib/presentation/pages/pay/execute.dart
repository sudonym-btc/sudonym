import 'package:flutter/material.dart' hide ButtonBar;
import 'package:sudonym/logic/index.dart';
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
}
