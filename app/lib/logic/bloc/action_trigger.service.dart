import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sudonym/config/index.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/logic/bloc/current_pot.service.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym.models/index.dart';

extension EitherX<L, R> on Either<L, R> {
  R asRight() => (this as Right).value; //
  L asLeft() => (this as Left).value;
}

extension SwitchMapExtension<T> on Stream<T> {
  // // Switches to a new stream if predicate matches
  // Stream<S> mapWhen<S>(
  //         bool Function(T value) pred, S Function(T val) map) =>
  //     map((value) => pred(value)
  //         ? map(value)
  //         : (() async* {
  //             yield value as S;
  //           })());
  // Switches to a new stream if predicate matches
  // Stream<S> switchMapWhen<S>(
  //         bool Function(T value) pred, Stream<S> Function(T val) map) =>
  //     switchMap((value) => pred(value)
  //         ? map(value)
  //         : (() async* {
  //             yield value as S;
  //           })());

  // Switches to new observable, where mapper takes a callback
  Stream<S> switchMapCallback<S>(
      Function(T value, Function(S event) next, dynamic Function(Object) err)
          callback) {
    return switchMap((value) {
      StreamController<S> controller = StreamController();
      callback(value, controller.sink.add, controller.sink.addError);
      return controller.stream;
    });
  }
}

class ActionStream {
  BuildContext context;
  String link;
  Pot? pot;
  ActionStream({required this.context, required this.link, this.pot});
}

@lazySingleton
@injectable
class ActionTriggerService with ActionLogger {
  final CallbackHandler<ActionParseResponse> callbacks =
      CallbackHandler<ActionParseResponse>();
  final CallbackHandler<ActionStream> actionStreamCallbacks =
      CallbackHandler<ActionStream>();

  ActionTriggerService() {
    actionStreamCallbacks.add((p0) {
      p0.pot ??= getIt<CurrentPotService>().pot;
      return p0;
    });
  }

  trigger(ActionStream action) {
    final triggerStream = PublishSubject<ActionStream>();

    loggy.d('Triggering action ${action.link}');
    if (!isValidAddress(action.link)) {
      loggy.e('Invalid link ${action.link}');
      throw Error();
    }
    triggerStream
        .asyncMap(actionStreamCallbacks.handle)
        .switchMapCallback(
            (value, void Function(ActionParseResponse x) next, err) =>
                Navigator.push(
                    action.context,
                    MaterialPageRoute(
                        builder: (context) => ActionPage(
                            address: value.link, onDone: next, onError: err))))
        .asyncMap(callbacks.handle)
        .switchMap((value) => value.payment != null
            ? handlePayment(action)(value.payment)
            : handleWithdraw(action)(value.withdraw))
        .handleError(
      (err) {
        loggy.e(err);
        throw err;
      },
      // test: (error) => error instanceof DioErr,
    ).listen((event) {
      loggy.d('Payment flow completed');
    });

    triggerStream.add(action);
  }

  handlePayment(
    ActionStream actionStream,
  ) {
    bool firstPageAmount = false;
    return (Payment a) => Stream.fromIterable([a])
        .map((event) {
          event.potId = actionStream.pot?.id;
          return event;
        })
        .switchMapCallback((value, Function(Payment) next, err) {
          if (PayManager.canChangeAmount(value)) {
            firstPageAmount = true;
            return Navigator.of(actionStream.context).pushReplacement(
                MaterialPageRoute(
                    builder: (context) => AmountPage<Payment>(
                        options:
                            getCurrencyInputOptions(actionStream.pot!, value),
                        onDone: (output) async {
                          value.amount = output.amount;
                          value.currency = output.currency;
                          next(value);
                        })));
          }
          return next(value);
        })
        .switchMapCallback((value, Function(Payment) next, err) {
          final route = MaterialPageRoute(
              builder: (context) => PayInfoPage(
                  action: value,
                  pot: actionStream.pot!,
                  onDone: next,
                  onError: err));
          if (firstPageAmount) {
            Navigator.push(
              actionStream.context,
              route,
            );
          } else {
            Navigator.pushReplacement(actionStream.context, route);
          }
        })
        .switchMapCallback((value, Function(Transaction) next, err) =>
            Navigator.pushReplacement(
                actionStream.context,
                PageRouteBuilder(
                    transitionDuration: const Duration(seconds: 0),
                    pageBuilder: (context, animation1, animation2) =>
                        PayExecutePage(
                            action: value, onDone: next, onError: err))))
        .doOnData((value) => Navigator.pushAndRemoveUntil(
            actionStream.context,
            MaterialPageRoute(
                builder: (context) => TransactionPage(entity: value)),
            (route) => route.isFirst));
  }

  handleWithdraw(ActionStream actionStream) {
    bool firstPageAmount = false;

    return (Withdraw a) => Stream.fromIterable([a])
        .map((event) {
          event.potId = actionStream.pot?.id;
          return event;
        })
        .switchMapCallback((value, Function(Withdraw) next, err) {
          if (WithdrawManager.canChangeAmount(value)) {
            firstPageAmount = true;
            return Navigator.of(actionStream.context).pushReplacement(
                MaterialPageRoute(
                    builder: (context) => AmountPage<Withdraw>(
                        options:
                            getCurrencyInputOptions(actionStream.pot!, value),
                        onDone: (output) async {
                          value.amount = output.amount;
                          value.currency = output.currency;
                          next(value);
                        })));
          }
          return next(value);
        })
        .switchMapCallback((value, Function(Withdraw) next, err) {
          final route = MaterialPageRoute(
              builder: (context) => WithdrawInfoPage(
                  action: value,
                  // pot: actionStream.pot,
                  onDone: next,
                  onError: err));
          if (firstPageAmount) {
            Navigator.push(
              actionStream.context,
              route,
            );
          } else {
            Navigator.pushReplacement(actionStream.context, route);
          }
        })
        .switchMapCallback((value, Function(Receiver) next, err) =>
            Navigator.pushReplacement(
                actionStream.context,
                PageRouteBuilder(
                    transitionDuration: const Duration(seconds: 0),
                    pageBuilder: (context, animation1, animation2) =>
                        WithdrawExecutePage(
                            action: value, onDone: next, onError: err))))
        .doOnData((value) => Navigator.pushAndRemoveUntil(
            actionStream.context,
            MaterialPageRoute(
                builder: (context) => ReceiverPage(entity: value)),
            (route) => route.isFirst));
    ;
  }

//   handleUnknown(BuildContext context) {
//     return (ActionParseResponse a) => Stream.fromIterable([a])
//         .where((event) => event.withdraw != null)
//         .map((event) => event.withdraw);
//   }
}

getCurrencyInputOptions(Pot pot, dynamic a) {
  return CurrencyInputOptions(
      currencies: [
        pot.currency,
        'USD',
        'BTC'
      ],
      max: [
        ...(a.maxAmount != null
            ? [CurrencyInputOutput(a.maxAmount, a.currency)]
            : []),
        ...(pot != null
            ? [
                CurrencyInputOutput(pot.spendableBalance, pot.currency),
              ]
            : [])
      ],
      min: [
        ...(a.minAmount != null
            ? [CurrencyInputOutput(a.minAmount, a.currency)]
            : [])
      ],
      initialCurrency: pot.currency,
      initialValue: CurrencyInputOutput(a.minAmount ?? 0, a.currency));
}

class CallbackHandler<T> {
  final List<T? Function(T)> callbacks = [];
  final List<T? Function(T)> after = [];

  add(T? Function(T) f) {
    callbacks.add(f);
  }

  remove(T? Function(T) f) {
    callbacks.remove(f);
  }

  handle(T? a) {
    T? r = callbacks.fold(a, (value, element) {
      if (value != null) {
        return element(value);
      }
      return null;
    });
    if (r != null) {
      after.fold(a, (value, element) {
        if (value != null) {
          return element(value);
        }
        return null;
      });
      return r;
    }
  }
}
