import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudonym/config/index.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym.models/index.dart';

class EntityCubitState<T> {
  T? entity;
  bool loading;

  EntityCubitState({this.entity, this.loading = false});
}

abstract class EntityCubit<
        EntityRepo extends CrudRepository<EntityType>,
        StateType extends EntityCubitState,
        EntityType extends BaseClass> extends Cubit<StateType>
    with CubitLogger, SafeEmit, WidgetsBindingObserver {
  EntityRepo repository = getIt<EntityRepo>();
  late Function stateClass;
  StreamSubscription? updater;
  bool shouldListen;
  bool Function(StateType)? shouldRefreshOnFocus;
  Timer? refresher;

  EntityCubit(
      {required StateType initialState,
      required this.stateClass,
      this.shouldRefreshOnFocus,
      this.shouldListen = true})
      : super(initialState) {
    WidgetsBinding.instance.addObserver(this);
  }

  listenChanges() {
    // Subscribe if not currently listening
    if (!shouldListen) return;
    updater ??= repository.updated.stream.listen((event) {
      if ((event.entity as dynamic).id == (state.entity as dynamic).id) {
        set(event.entity);
      }
    });
  }

  fetch(dynamic id) async {
    safeEmit(stateClass(entity: state.entity, loading: true));
    EntityType? updated;
    StreamSubscription fetchSub = repository.updated.stream.listen((event) {
      if ((event.entity as dynamic).id == (state.entity as dynamic).id) {
        updated = event.entity;
      }
    });
    set(await repository.fetch(id));
    fetchSub.cancel();
    if (updated != null) {
      set(updated!);
    }
  }

  createOrUpdate(EntityType params) {
    if ((params as dynamic).id != null) {
      return update(params);
    }
    return create(params);
  }

  create(EntityType params) async {
    safeEmit(stateClass(entity: null, loading: true));
    return set(await repository.create(params.toJson()));
  }

  update(EntityType params) async {
    safeEmit(stateClass(entity: null, loading: true));
    return set(await repository.update(params.toJson()));
  }

  EntityType set(EntityType entity) {
    safeEmit(stateClass(entity: entity, loading: false)) &&
        (listenChanges() ?? true);
    return entity;
  }

  setRefresher(Duration d, bool Function(StateType) refresh) {
    refresher = Timer.periodic(d, (timer) {
      if (refresh(state)) {
        fetch(state.entity.toJson()['id']);
      }
    });
  }

  setFocusRefresher(bool Function(StateType) refresh) {
    shouldRefreshOnFocus = refresh;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState appState) {
    if (appState == AppLifecycleState.resumed &&
        state.entity != null &&
        shouldRefreshOnFocus != null &&
        shouldRefreshOnFocus!(state)) {
      loggy.d('Changed app state registered in cubit state');
      loggy.d('Reloading entity due to state change');
      fetch(state.entity.toJson()['id']);
    }
  }

  @override
  Future<void> close() {
    if (updater != null) {
      updater!.cancel();
    }
    if (refresher != null) {
      refresher!.cancel();
    }
    WidgetsBinding.instance.removeObserver(this);
    return super.close();
  }
}
