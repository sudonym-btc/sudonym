import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/config/index.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';

@lazySingleton
@injectable
class ActionTriggerService with ActionLogger {
  Stream<R> step<R>(
      BuildContext context, dynamic data, Function(Sink s) action) {
    StreamController<R> controller = StreamController<R>();
    action(controller.sink);
    return controller.stream;
  }

  trigger(String link, BuildContext context, [Pot? pot]) {
    final subject = PublishSubject();
    subject.switchMap<ActionParseResponse>((value) {
      return step<ActionParseResponse>(
          context,
          value,
          (sink) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ActionPage(address: link, onDone: sink.add))));
    }).switchMap((event) {
      if (event.payment != null) {
        return handlePayment(context)(event);
      } else if (event.withdraw != null) {
        return handleWithdraw(context)(event);
      }
      return handleUnknown(context)(event);
    }).listen((event) {});

    subject.add(link);
  }

  handlePayment(
    BuildContext context,
  ) {
    bool firstPageAmount = false;
    return (ActionParseResponse a) => Stream.fromIterable([a])
        .map<Payment>((event) => event.payment)
        .switchMap<Payment>((value) {
          if (PayManager.canChangeAmount(value)) {
            firstPageAmount = true;
            return step<Payment>(
                context,
                value,
                (sink) => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (context) => AmountPage<Payment>(
                            action: value, onDone: sink.add))));
          }
          return () async* {
            yield value;
          }();
        })
        .switchMap<Payment>((value) => step(context, value, (sink) {
              final route = MaterialPageRoute(
                  builder: (context) =>
                      PayInfoPage(action: value, onDone: sink.add));
              if (firstPageAmount) {
                Navigator.push(
                  context,
                  route,
                );
              } else {
                Navigator.pushReplacement(context, route);
              }
            }))
        .switchMap<Transaction>((value) => step(
            context,
            value,
            (sink) => Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                    transitionDuration: const Duration(seconds: 0),
                    pageBuilder: (context, animation1, animation2) =>
                        PayExecutePage(action: value, onDone: sink.add)))))
        .switchMap((value) => step(
            context,
            value,
            (sink) => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => TransactionPage(entity: value)),
                (route) => route.isFirst)));
  }

  handleWithdraw(BuildContext context) {
    return (ActionParseResponse a) =>
        Stream.fromIterable([a]).map((event) => event.withdraw);
  }

  handleUnknown(BuildContext context) {
    return (ActionParseResponse a) => Stream.fromIterable([a])
        .where((event) => event.withdraw != null)
        .map((event) => event.withdraw);
  }
}
