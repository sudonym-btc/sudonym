import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudonym.models/base-class.dart';
import 'package:sudonym/data/repository/crud_repository.dart';

class EntityCubitState<T> {
  T? entity;
  bool loading = false;

  EntityCubitState({this.entity, this.loading = false});
}

abstract class EntityCubit<StateType, EntityType extends BaseClass>
    extends Cubit<StateType> {
  late CrudRepository repository;
  late Function stateClass;
  StreamSubscription? updater;

  EntityCubit(StateType initialState, this.stateClass) : super(initialState);

  fetch(dynamic id) async {
    emit(stateClass(entity: null, loading: true));
    dynamic x = stateClass(entity: await repository.fetch(id), loading: false);
    if (!isClosed) {
      emit(x);
      updater = repository.updated.stream.listen((event) {
        if (event.get("id") == id) {
          emit(stateClass(entity: event, loading: false));
        }
      });
    }
  }

  createOrUpdate(EntityType params) {
    if (params.get("id") != null) {
      return update(params);
    }
    return create(params);
  }

  create(EntityType params) async {
    emit(stateClass(entity: null, loading: true));
    dynamic x =
        stateClass(entity: await repository.create(params), loading: false);
    if (!isClosed) {
      emit(x);
    }
  }

  update(EntityType params) async {
    emit(stateClass(entity: null, loading: true));
    dynamic x =
        stateClass(entity: await repository.update(params), loading: false);
    if (!isClosed) {
      emit(x);
    }
  }

  set(EntityType entity) {
    emit(stateClass(entity: entity, loading: false));
  }

  @override
  Future<void> close() {
    if (updater != null) {
      updater!.cancel();
    }
    return super.close();
  }
}
