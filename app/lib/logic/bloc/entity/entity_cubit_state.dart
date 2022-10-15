import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudonym.models/base-class.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/config/logger.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';

class EntityCubitState<T> {
  T? entity;
  bool loading;

  EntityCubitState({this.entity, this.loading = false});
}

abstract class EntityCubit<
    EntityRepo extends CrudRepository<EntityType>,
    StateType extends EntityCubitState,
    EntityType extends BaseClass> extends Cubit<StateType> with CubitLogger {
  EntityRepo repository = getIt<EntityRepo>();
  late Function stateClass;
  StreamSubscription? updater;
  bool shouldListen;

  EntityCubit(
      {required StateType initialState,
      required this.stateClass,
      this.shouldListen = true})
      : super(initialState);

  listenChanges() {
    // Subscribe if not currently listening
    if (!shouldListen) return;
    updater ??= repository.updated.stream.listen((event) {
      if ((event as dynamic).id == (state.entity as dynamic).id) {
        set(event);
      }
    });
  }

  fetch(dynamic id) async {
    emit(stateClass(entity: null, loading: true));
    set(await repository.fetch(id));
  }

  createOrUpdate(EntityType params) {
    if ((params as dynamic).id != null) {
      return update(params);
    }
    return create(params);
  }

  create(EntityType params) async {
    emit(stateClass(entity: null, loading: true));
    set(await repository.create(params.toJson()));
  }

  update(EntityType params) async {
    emit(stateClass(entity: null, loading: true));
    set(await repository.update(params.toJson()));
  }

  set(EntityType entity) {
    if (!isClosed) {
      emit(stateClass(entity: entity, loading: false));
      listenChanges();
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
