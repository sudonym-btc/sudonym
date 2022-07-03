import 'package:dio/dio.dart';
import 'package:sudonym.models/types/list.dart';
import 'package:sudonym.models/mock/parsed_data.dart';
import 'package:sudonym/config/config.dart';

import '../../repository/crud_repository.dart' as real;
import '../../repository/websocket.dart';

const requestDelay = Duration(seconds: 1);

// ignore: camel_case_types
abstract class crud_repository<T> extends real.crud_repository<T> {
  List<T> data = [];
  List<T> availableData = [];

  crud_repository(Config config, Dio dio, Websocket websocket)
      : super(config, dio, websocket) {
    availableData = Mockdata.getData<T>(endpoint);
  }

  @override
  Future<T> create(params) async {
    availableData.add(params);
    created.add(params);
    return params;
  }

  @override
  Future<T> fetch(dynamic id) async {
    await Future.delayed(requestDelay);
    return availableData.firstWhere((e) => (e as dynamic).id == id);
  }

  @override
  Future<ListState<T>> list({where}) async {
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
