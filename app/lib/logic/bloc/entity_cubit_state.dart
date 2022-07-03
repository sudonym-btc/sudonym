import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudonym/data/repository/crud_repository.dart';

class EntityCubitState<T> {
  T? entity;
  bool loading = false;

  EntityCubitState({this.entity, this.loading = false});
}

abstract class EntityCubit<StateType> extends Cubit<StateType> {
  late crud_repository repository;
  late Function stateClass;
  StreamSubscription? updater;

  EntityCubit(StateType initialState, this.stateClass) : super(initialState);

  fetch(dynamic id) async {
    emit(stateClass(entity: null, loading: true));
    dynamic x = stateClass(entity: await repository.fetch(id), loading: false);
    if (!isClosed) {
      emit(x);
      updater = repository.updated.stream.listen((event) {
        if (event.id == id) {
          emit(stateClass(entity: event, loading: false));
        }
      });
    }
  }

  @override
  Future<void> close() {
    if (updater != null) {
      updater!.cancel();
    }
    return super.close();
  }
}
