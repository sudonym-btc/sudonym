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

  PotListReorganizerCubit({required this.list, required this.controller})
      : super(PotListState());

  canMoveLeft(Pot p) {
    if (p.PotUsers[0].index > list.state.data.first.PotUsers[0].index) {
      return true;
    }
    return false;
  }

  canMoveRight(Pot p) {
    if (p.PotUsers[0].index < list.state.data.last.PotUsers[0].index) {
      return true;
    }
    return false;
  }

  onMoveLeft(Pot p) {
    Map<String, dynamic> d = {
      ...p.PotUsers[0].toJson(),
      'index': p.PotUsers[0].index--
    };
    getIt<PotUserRepository>().update(d);
    controller.previousPage(
        duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
    list.setData([
      ...list.state.data.where((element) =>
          element.PotUsers[0].index < p.PotUsers[0].index - 1 &&
          element.id != p.id),
      p,
      ...list.state.data.where((element) =>
          element.PotUsers[0].index >= p.PotUsers[0].index - 1 &&
          element.id != p.id),
    ]);
  }

  onMoveRight(Pot p) {
    Map<String, dynamic> d = {
      ...p.PotUsers[0].toJson(),
      'index': p.PotUsers[0].index++
    };
    getIt<PotUserRepository>().update(d);
    controller.nextPage(
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    list.setData([
      ...list.state.data.where((element) =>
          element.PotUsers[0].index < p.PotUsers[0].index + 1 &&
          element.id != p.id),
      p,
      ...list.state.data.where((element) =>
          element.PotUsers[0].index >= p.PotUsers[0].index + 1 &&
          element.id != p.id),
    ]);
  }

  reorgData() {}
}

class PotListState {}
