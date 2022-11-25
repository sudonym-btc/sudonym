import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym.models/index.dart';

@injectable
class PotListReorganizerCubit extends Cubit<PotListState> {
  ListCubit<Pot> list;
  PageController controller;
  PotRepository potRepository = getIt<PotRepository>();

  PotListReorganizerCubit({required this.list, required this.controller})
      : super(PotListState()) {
    potRepository.deleted.stream.listen(onDelete);
  }

  canMoveLeft(Pot p) {
    if (list.state.data.indexOf(p) > 0) {
      return true;
    }
    return false;
  }

  canMoveRight(Pot p) {
    if (list.state.data.indexOf(p) < list.state.data.length - 1) {
      return true;
    }
    return false;
  }

  onDelete(Pot p) {
    list.setData(
        list.state.data.where((element) => element.id != p.id).toList());
  }

  onMoveLeft(Pot p) async {
    Map<String, dynamic> d = {
      ...p.PotUsers[0].toJson(),
      'index': list.state.data.indexOf(p)
    };
    await getIt<PotUserRepository>().update(d);
    controller.previousPage(
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    list.setData([
      ...list.state.data.sublist(0, list.state.data.indexOf(p) - 1),
      p,
      list.state.data[list.state.data.indexOf(p) - 1],
      ...list.state.data
          .sublist(list.state.data.indexOf(p) + 1, list.state.data.length),
    ]);
  }

  onMoveRight(Pot p) async {
    Map<String, dynamic> d = {
      ...p.PotUsers[0].toJson(),
      'index': list.state.data.indexOf(p) + 2
    };
    getIt<PotUserRepository>().update(d);
    controller.nextPage(
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    list.setData([
      ...list.state.data.sublist(0, list.state.data.indexOf(p)),
      list.state.data[list.state.data.indexOf(p) + 1],
      p,
      ...list.state.data
          .sublist(list.state.data.indexOf(p) + 1, list.state.data.length),
    ]);
  }
}

class PotListState {}
