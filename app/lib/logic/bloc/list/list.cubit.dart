import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudonym/data/repository/crud_repository.dart';
import 'package:sudonym.models/types/list.dart';

class ListCubit<T> extends Cubit<ListCubitState> {
  final crud_repository _repository;
  int firstId = 0;
  int lastId = 123456789987654321;
  String order = 'DESC';

  ListCubit(this._repository)
      : super(ListCubitState(data: [], metadata: {}, loading: false)) {
    _repository.created.stream.listen((event) {
      print("CREATETETTEE");
      this.loadNext();
    });
  }

  loadNext() async {
    if (!state.loading) {
      emit(ListCubitState(
          data: state.data, metadata: state.metadata, loading: true));

      var response = await _repository.list(where: {
        'id': order == 'ASC' ? {'gt': lastId} : {'lt': lastId}
      });

      List elements = [...state.data, ...response.data];
      List sorted = [...elements];
      sorted.sort(((a, b) => a.id - b.id));
      if (order == 'ASC') {
        sorted = sorted.reversed.toList();
      }
      lastId = sorted[0].id;

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
        'id': order == 'ASC' ? {'lt': firstId} : {'gt': firstId}
      });

      List elements = [...response.data, ...state.data];
      List sorted = [...elements];
      sorted.sort(((a, b) => a.id - b.id));
      lastId = sorted[0].id;

      if (!isClosed) {
        emit(ListCubitState(
            data: elements, metadata: response.metadata, loading: false));
      }
    }
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
