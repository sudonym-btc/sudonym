import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
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
            StatusPage(color: Colors.indigo.shade800, content: loader));
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
}
