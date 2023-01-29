import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart' hide ButtonBar;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym.models/index.dart';

class TaskBuilder<T> extends StatelessWidget {
  final Future<Either<Object, T>> Function() future;
  final Widget Function(BuildContext context, T data)? onSuccess;
  final Widget Function(BuildContext context, Object err) onError;
  final Widget Function(BuildContext context, dynamic data)? onLoading;

  const TaskBuilder(
      {required this.future,
      this.onSuccess,
      required this.onError,
      this.onLoading,
      super.key});

  _getLoader() {
    return (onLoading ??
        (BuildContext context, dynamic data) =>
            StatusPage(color: loadingColor, content: loader));
  }

  _getSuccess() {
    return (onSuccess ?? _getLoader());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: future(),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            return snapshot.data!.fold(
                (l) => onError(context, l), (r) => _getSuccess()(context, r));
          }
          return _getLoader()(context, null);
        }));
  }
}

abstract class ActionFlow<Model extends ActionType, Response>
    extends StatelessWidget {
  const ActionFlow({required this.onDone, super.key, required this.onError});

  final void Function(Response obj) onDone;
  final Function(Object obj) onError;

  StatusPage errorPage(BuildContext context, Object err) {
    return errorPageGenerator(context, err);
  }
}

StatusPage errorPageGenerator(BuildContext context, Object err) {
  Text content = Text(err.toString());
  if (err is DioError) {
    content = Text(err.response.toString());
    if (err.response?.data is LNURLProtocolError) {
      content = Text(err.response?.data.data);
    }
    if (err.response?.data is BalanceLowError) {
      content = Text(AppLocalizations.of(context)!.balanceLowError(
          FormatCurrency().format(err.response?.data.amount.currency,
              err.response?.data.amount.amount),
          FormatCurrency().format(err.response?.data.amountLeft.currency,
              err.response?.data.amountLeft.amount)));
    }
  }
  return StatusPage(
      color: Theme.of(context).errorColor,
      title: AppLocalizations.of(context)!.failed,
      content: content,
      actions: ButtonBar(
        children: [
          Button(
            onPressed: () {
              Navigator.of(context).pop();
            },
            text: AppLocalizations.of(context)!.back,
          )
        ],
      ));
}
