import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudonym/data/repository/crud_repository.dart';

class EntityCubitState<T> {
  // EntityCubitState.init() : this(null,false);

  T? entity;
  bool loading = false;

  EntityCubitState({this.entity, this.loading = false});
}

abstract class EntityCubit<StateType> extends Cubit<StateType> {
  late crud_repository repository;
  late Function stateClass;

  EntityCubit(StateType initialState, this.stateClass) : super(initialState) {
    fetch();
  }

  fetch() async {
    emit(stateClass(entity: null, loading: true));
    emit(stateClass(entity: await repository.fetch("1"), loading: false));
  }
}
