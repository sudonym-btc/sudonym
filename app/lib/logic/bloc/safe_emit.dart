import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

mixin SafeEmit<T> on Cubit<T> {
  bool safeEmit(T state) {
    if (isClosed) return false;
    emit(state);
    return true;
  }
}

mixin SafeState<T extends StatefulWidget> on State<T> {
  void safeState(void Function() cb) {
    if (!mounted) return;
    setState(cb);
  }
}
