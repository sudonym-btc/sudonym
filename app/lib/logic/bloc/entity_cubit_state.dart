import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudonym.models/base-class.dart';
import 'package:sudonym/data/repository/crud_repository.dart';

class EntityCubitState<T> {
  T? entity;
  bool loading = false;

  EntityCubitState({this.entity, this.loading = false});
}

abstract class EntityCubit<StateType extends EntityCubitState,
    EntityType extends BaseClass> extends Cubit<StateType> {
  late CrudRepository repository;
  late Function stateClass;
  StreamSubscription? updater;

  EntityCubit(StateType initialState, this.stateClass) : super(initialState);

  listenChanges() {
    updater = repository.updated.stream.listen((event) {
      if ((event as dynamic).id == (state.entity as dynamic).id) {
        if (!isClosed) {
          emit(stateClass(entity: event, loading: false));
        }
      }
    });
  }

  fetch(dynamic id) async {
    emit(stateClass(entity: null, loading: true));
    dynamic x = stateClass(entity: await repository.fetch(id), loading: false);
    if (!isClosed) {
      emit(x);
      listenChanges();
    }
  }

  createOrUpdate(EntityType params) {
    if ((params as dynamic).id != null) {
      return update(params);
    }
    return create(params);
  }

  create(EntityType params) async {
    emit(stateClass(entity: null, loading: true));
    dynamic x = stateClass(
        entity: await repository.create(params.toJson()), loading: false);
    if (!isClosed) {
      emit(x);
    }
  }

  update(EntityType params) async {
    emit(stateClass(entity: null, loading: true));
    dynamic x = stateClass(
        entity: await repository.update(params.toJson()), loading: false);
    if (!isClosed) {
      emit(x);
    }
  }

  set(EntityType entity) {
    emit(stateClass(entity: entity, loading: false));
    listenChanges();
  }

  @override
  Future<void> close() {
    if (updater != null) {
      updater!.cancel();
    }
    return super.close();
  }
}
