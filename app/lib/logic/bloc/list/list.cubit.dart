import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudonym/config/logger.dart';
import 'package:sudonym.models/types/list.dart';
import 'package:sudonym/data/index.dart';

class ListCubit<T> extends Cubit<ListCubitState> with ListLogger {
  final CrudRepository _repository;
  final Map<String, dynamic> where;
  String order = 'DESC';
  StreamSubscription? updater;

  ListCubit(this._repository, {this.where = const {}})
      : super(ListCubitState(
            data: const [], metadata: const {}, loading: false)) {
    if (updater == null) {
      loggy.d('Subscribing to ${_repository.endpoint}');
    }
    updater ??= _repository.created.stream.listen((event) async {
      loggy.d(
          "Created ${event.toJson()["id"].toString()} reloading ${_repository.endpoint}");
      await loadPrevious();
    });
  }

  filter(List x) {
    return x
        .where((element) =>
            !state.data.map((e) => e.id).contains(element.toJson()['id']))
        .toList();
  }

  loadNext() async {
    if (isClosed) return;
    if (!state.loading) {
      loggy.d('Loading next ${_repository.endpoint}');

      emit(ListCubitState(
          data: state.data, metadata: state.metadata, loading: true));

      var response = await _repository.list(where: {
        ...where,
        'id': order == 'DESC' ? {'lt': getSmallestId()} : {'lt': getLargestId()}
      });
      List filtered = filter(response.data);
      List elements = [...state.data, ...filtered];

      if (!isClosed) {
        emit(ListCubitState(
            data: elements, metadata: response.metadata, loading: false));
      }
    }
  }

  loadPrevious() async {
    if (isClosed) return;

    if (!state.loading) {
      loggy.d('Loading previous ${_repository.endpoint}');

      emit(ListCubitState(
          data: state.data, metadata: state.metadata, loading: true));

      var response = await _repository.list(where: {
        ...where,
        'id': order == 'DESC' ? {'gt': getLargestId()} : {'gt': getSmallestId()}
      });

      List filtered = filter(response.data);
      List elements = [...filtered, ...state.data];

      if (!isClosed) {
        emit(ListCubitState(
            data: elements, metadata: response.metadata, loading: false));
      }
    }
  }

  getLargestId() {
    return state.data.fold(
        0,
        (previousValue, element) =>
            element.id > previousValue ? element.id : previousValue);
  }

  getSmallestId() {
    return state.data.fold(
        99999999999999,
        (previousValue, element) =>
            element.id < previousValue ? element.id : previousValue);
  }

  @override
  close() async {
    loggy.d('Unsubscribing to ${_repository.endpoint}');
    await updater?.cancel();
    return super.close();
  }
}

class ListCubitState<T> extends Equatable implements ListState<T> {
  @override
  List<T> data;
  @override
  dynamic metadata;
  bool loading;

  ListCubitState(
      {required this.data, required this.metadata, required this.loading});

  @override
  List<Object?> get props => [data, metadata, loading];
}
