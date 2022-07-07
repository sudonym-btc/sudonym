import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudonym/data/repository/crud_repository.dart';
import 'package:sudonym.models/types/list.dart';

class ListCubit<T> extends Cubit<ListCubitState> {
  final CrudRepository _repository;
  final Map<String, dynamic> where;
  String order = 'DESC';

  ListCubit(this._repository, {this.where = const {}})
      : super(ListCubitState(
            data: const [], metadata: const {}, loading: false)) {
    _repository.created.stream.listen((event) {
      print("Loading Prev");
      loadPrevious();
    });
  }

  loadNext() async {
    if (!state.loading) {
      emit(ListCubitState(
          data: state.data, metadata: state.metadata, loading: true));

      var response = await _repository.list(where: {
        ...where,
        'id': order == 'DESC' ? {'lt': getSmallestId()} : {'lt': getLargestId()}
      });

      List elements = [...state.data, ...response.data];

      if (!isClosed) {
        emit(ListCubitState(
            data: elements, metadata: response.metadata, loading: false));
      }
    }
  }

  loadPrevious() async {
    if (!state.loading) {
      emit(ListCubitState(
          data: state.data, metadata: state.metadata, loading: true));

      var response = await _repository.list(where: {
        ...where,
        'id': order == 'DESC' ? {'gt': getLargestId()} : {'gt': getSmallestId()}
      });

      List elements = [...response.data, ...state.data];

      if (!isClosed) {
        emit(ListCubitState(
            data: elements, metadata: response.metadata, loading: false));
      }
    }
  }

  getLargestId() {
    return state.data.fold(
        0,
        (previousValue, element) => element.get("id") > previousValue
            ? element.get("id")
            : previousValue);
  }

  getSmallestId() {
    return state.data.fold(
        99999999999999,
        (previousValue, element) => element.get("id") < previousValue
            ? element.get("id")
            : previousValue);
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
