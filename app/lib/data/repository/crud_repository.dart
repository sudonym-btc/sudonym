import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:sudonym.models/base-class.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym.models/types/list.dart';
import 'package:sudonym/config/config.dart';
import 'package:sudonym/config/repository-logger.dart';
import 'package:sudonym/data/repository/websocket.dart';

const List<List<String>> order = [
  ["id", "DESC"]
];

abstract class CrudRepository<T extends BaseClass> with RepoLogger {
  String endpoint = "";
  Function converter = <T>(obj) {
    throw Error();
  };
  Dio dio;
  Config config;
  Websocket websocket;
  StreamController<T> updated = StreamController.broadcast();
  StreamController<T> created = StreamController.broadcast();

  CrudRepository(this.config, this.dio, this.websocket) {
    onInit();
  }

  onInit() {
    loggy.debug("Listening to this stream $endpoint");
    websocket.getStream().listen((event) {
      Event e = Event(jsonDecode(event));
      if (e.get("name").split('.')[0] == endpoint.toLowerCase()) {
        loggy.debug("Websocket: " + event);
        if (e.get("name").split('.')[1] == 'created') {
          created.add(converter(e.get("data")));
        } else if (e.get("name").split('.')[1] == 'updated') {
          updated.add(converter(e.get("data")));
        }
      }
    });
  }

  Future<T> fetch(dynamic id) async {
    return dio.get("/$endpoint/$id").then((value) {
      return converter(value.data);
    });
  }

  Future<ListState<T>> list(
      {Map<String, dynamic>? where, List<List<String>>? order = order}) async {
    return dio.get("/$endpoint",
        queryParameters: {"where": where, "order": order}).then((value) {
      var list = (value.data["data"] as List).map((e) {
        return converter(e) as T;
      }).toList();

      return ListState(list, {});
    });
  }

  Future<T> create(T entity) async {
    return dio.post("/$endpoint", data: entity).then((value) {
      return converter(value.data);
    });
  }

  Future<T> update(T entity) async {
    return dio
        .put("/$endpoint/" + entity.get("id"), data: entity)
        .then((value) {
      return converter(value.data);
    });
  }

  Future<ListState<T>> search(String term) async {
    return dio.get("/$endpoint").then((value) {
      var list = (value.data as List).map((e) {
        return converter(e) as T;
      }).toList();

      return ListState(list, {});
    });
  }
}
