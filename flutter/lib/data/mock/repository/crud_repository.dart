import 'package:dio/dio.dart';
import 'package:sudonym.models/types/list.dart';
import 'package:sudonym.models/mock/parsed_data.dart';

import '../../repository/crud_repository.dart' as real;
import '../../repository/websocket.dart';

const requestDelay = Duration(seconds: 1);

// ignore: camel_case_types
abstract class crud_repository<T> extends real.crud_repository<T> {
  List<T> data = [];
  dynamic availableData = [];

  crud_repository(Dio dio, Websocket websocket) : super(dio, websocket) {
    availableData = Mockdata.getData<T>(endpoint);
  }

  // @override
  // Future<T> create() async {
  //   // TODO: implement create
  //   throw UnimplementedError();
  // }

  @override
  Future<T> fetch(String id) async {
    await Future.delayed(requestDelay);
    return availableData[0];
  }

  @override
  Future<ListState<T>> list() async {
    await Future.delayed(requestDelay);
    return ListState(availableData, {});
  }

  @override
  Future<ListState<T>> search(String search) async {
    await Future.delayed(requestDelay);
    return ListState(availableData, {});
  }

  // @override
  // Future<T> update() async {
  //   // TODO: implement update
  //   throw UnimplementedError();
  // }
}
