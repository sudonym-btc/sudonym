import 'package:flutter_bloc/flutter_bloc.dart';

mixin SafeEmit<T> on Cubit<T> {
  bool safeEmit(T state) {
    if (isClosed) return false;
    emit(state);
    return true;
  }
}
