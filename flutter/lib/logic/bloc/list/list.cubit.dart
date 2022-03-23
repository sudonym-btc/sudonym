import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudonym/data/repository/crud_repository.dart';
import 'package:sudonym.models/types/list.dart';

class ListCubit<T> extends Cubit<ListCubitState> {
  final crud_repository _repository;
  ListCubit(this._repository)
      : super(ListCubitState(data: [], metadata: {}, loading: false));

  loadNext() async {

    if (!state.loading) {
      emit(ListCubitState(
          data: state.data, metadata: state.metadata, loading: true));
      var response = await _repository.list();
      List elements = [...state.data, ...response.data];
      emit(ListCubitState(
          data: elements, metadata: response.metadata, loading: false));
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
