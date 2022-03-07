import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudonym/data/repository/crud_repository.dart';
import 'package:sudonym.models/types/list.dart';

class ListCubit<T> extends Cubit<ListCubitState> {
  final crud_repository _repository;
  ListCubit(this._repository)
      : super(ListCubitState(data: [], metadata: {}, loading: false));

  loadNext() async {
    emit(ListCubitState(
        data: this.state.data, metadata: this.state.metadata, loading: true));
    var response = await _repository.list();
    emit(ListCube(
        data: response.data, metadata: response.metadata, loading: false));
  }
}

class ListCubitState<T> extends Equatable implements ListState<T> {
  List<T> data;
  dynamic metadata;
  bool loading;

  ListCubitState(
      {required this.data, required this.metadata, required this.loading});

  @override
  List<Object?> get props => [data, metadata, loading];
}
class ListCube<T> extends ListCubitState<T> {
  ListCube({required List<T> data, required metadata, required bool loading}) : super(data: data, metadata: metadata, loading: loading);

}