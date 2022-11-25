import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudonym/config/index.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/logic/index.dart';

class ListCubit<T> extends Cubit<ListCubitState> with ListLogger, SafeEmit {
  final CrudRepository _repository;
  Map<String, dynamic> where;
  String order = 'DESC';
  StreamSubscription? onCreated;
  StreamSubscription? onUpdated;

  ListCubit(this._repository, {this.where = const {}})
      : super(const ListCubitState(data: [], metadata: {}, loading: false)) {
    if (onCreated == null) {
      loggy.d('Subscribing to ${_repository.endpoint}');
    }
    onCreated ??= _repository.created.stream.listen((event) async {
      loggy.d(
          "Created ${event.toJson()["id"].toString()} reloading ${_repository.endpoint}");
      await loadPrevious();
    });

    onUpdated ??= _repository.updated.stream.listen((event) async {
      safeEmit(state.copyWith(
          data: state.data
              .map((e) => e.id == (event as dynamic).id ? event : e)
              .toList()));
    });
  }

  filter(List x) {
    return x
        .where((element) =>
            !state.data.map((e) => e.id).contains(element.toJson()['id']))
        .toList();
  }

  setWhere(Map<String, dynamic> w) {
    where = w;
  }

  loadNext() async {
    if (!state.loading) {
      loggy.d('Loading next ${_repository.endpoint}');

      safeEmit(state.copyWith(loading: true, loadingNext: true));

      var response = await _repository.list(where: {
        ...where,
        'id': order == 'DESC' ? {'lt': getSmallestId()} : {'lt': getLargestId()}
      });
      List filtered = filter(response.data);
      List elements = [...state.data, ...filtered];

      safeEmit(state.copyWith(
          data: elements,
          metadata: response.metadata,
          loading: false,
          loadingNext: false));
    }
  }

  loadPrevious() async {
    if (!state.loading) {
      loggy.d('Loading previous ${_repository.endpoint}');

      safeEmit(state.copyWith(loading: true, loadingPrevious: true));

      var response = await _repository.list(where: {
        ...where,
        'id': order == 'DESC' ? {'gt': getLargestId()} : {'gt': getSmallestId()}
      });

      List filtered = filter(response.data);
      List elements = [...filtered, ...state.data];

      safeEmit(state.copyWith(
          data: elements,
          metadata: response.metadata,
          loading: false,
          loadingPrevious: false));
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

  setData(List<dynamic> data) {
    safeEmit(state.copyWith(data: data));
  }

  @override
  close() async {
    loggy.d('Unsubscribing to ${_repository.endpoint}');
    await onCreated?.cancel();
    await onUpdated?.cancel();
    return super.close();
  }

  reset() {
    safeEmit(const ListCubitState(data: [], metadata: {}, loading: false));
  }
}

class ListCubitState<T> extends Equatable {
  final List<T> data;
  final dynamic metadata;
  final bool loading;
  final bool loadingPrevious;
  final bool loadingNext;

  const ListCubitState(
      {required this.data,
      required this.metadata,
      this.loading = false,
      this.loadingPrevious = false,
      this.loadingNext = false});

  ListCubitState copyWith({
    List<T>? data,
    dynamic metadata,
    bool? loading,
    bool? loadingPrevious,
    bool? loadingNext,
  }) =>
      ListCubitState(
        data: data ?? this.data,
        metadata: metadata ?? this.metadata,
        loading: loading ?? this.loading,
        loadingNext: loadingNext ?? this.loadingNext,
        loadingPrevious: loadingPrevious ?? this.loadingPrevious,
      );

  @override
  List<Object?> get props =>
      [data, metadata, loading, loadingNext, loadingPrevious];
}
