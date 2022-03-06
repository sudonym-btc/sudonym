import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudonym/data/repository/crud_repository.dart';
import 'package:sudonym.models/types/list.dart';

class ListCubit<T> extends Cubit<ListState> {
  crud_repository _repository;
  ListCubit(this._repository) : super(ListState([], {}));

  loadNext() async {
    emit(await _repository.list());
  }
}