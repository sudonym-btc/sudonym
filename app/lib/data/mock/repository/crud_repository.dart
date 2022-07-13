import 'package:dio/dio.dart';
import 'package:sudonym.models/types/list.dart';
import 'package:sudonym.models/mock/parsed_data.dart';
import 'package:sudonym.models/base-class.dart';
import 'package:sudonym/config/config.dart';

import '../../repository/crud_repository.dart';
import '../../repository/websocket.dart';

const requestDelay = Duration(seconds: 1);

// ignore: camel_case_types
abstract class MockCrudRepository<T extends BaseClass>
    extends CrudRepository<T> {
  List<T> data = [];
  List<T> availableData = [];

  MockCrudRepository(Config config, Dio dio, Websocket websocket)
      : super(config, dio, websocket) {
    availableData = Mockdata.getData<T>(endpoint);
  }

  @override
  Future<T> create(T entity) async {
    var sorted = availableData.map((dynamic e) => e.get("id")).toList();
    sorted.sort();
    entity["id"] = sorted.last + 1;
    availableData.add(entity);
    created.add(entity);
    return entity;
  }

  @override
  Future<T> fetch(dynamic id) async {
    await Future.delayed(requestDelay);
    return availableData.firstWhere((dynamic e) => e!.get("id") == id);
  }

  @override
  Future<ListState<T>> list(
      {Map<String, dynamic>? where, List<List<String>>? order}) async {
    await Future.delayed(requestDelay);
    return ListState(
        availableData.where((element) {
          if (where == null) {
            return true;
          } else {
            return where.keys.every((key) {
              if (where[key].runtimeType == int) {
                return element.get(key) == where[key];
              }
              if (where[key]["gt"] != null) {
                return element.get(key) > where[key]["gt"];
              }
              if (where[key]["lt"] != null) {
                return element.get(key) < where[key]["lt"];
              }
              return false;
            });
          }
        }).toList(),
        {});
  }

  @override
  Future<T> update(T entity) async {
    await Future.delayed(requestDelay);
    return availableData.firstWhere((e) => e.get("id") == entity.get("id"));
  }

  @override
  Future<ListState<T>> search(String term) async {
    await Future.delayed(requestDelay);
    return ListState(availableData, {});
  }
}
