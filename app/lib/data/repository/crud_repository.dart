import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym.models/types/list.dart';
import 'package:sudonym/config/config.dart';
import 'package:sudonym/data/repository/websocket.dart';

abstract class crud_repository<T> {
  String endpoint = "";
  Function converter = <T>(obj) {};
  Dio dio;
  Config config;
  Websocket websocket;
  StreamController<T> updated = StreamController.broadcast();
  StreamController<T> created = StreamController.broadcast();

  crud_repository(this.config, this.dio, this.websocket) {
    onInit();
  }

  onInit() {
    print("Listening to this stream " + endpoint);
    websocket.getStream().listen((event) {
      print("Websocket: " + event);
      Event e = Event.fromJson(jsonDecode(event));
      if (e.name.split('.')[0] == endpoint) {
        if (e.name.split('.')[1] == 'created') {
          created.add(converter(e.data));
        } else if (e.name.split('.')[1] == 'updated') {
          updated.add(converter(e.data));
        }
      }
    });
  }

  Future<T> fetch(dynamic id) async {
    return dio.get("/" + endpoint + "/" + id.toString()).then((value) {
      return converter(value.data);
    });
  }

  Future<ListState<T>> list() async {
    return dio.get("/" + endpoint).then((value) {
      var list = (value.data as List).map((e) {
        return converter(e) as T;
      }).toList();

      return ListState(list, {});
    });
  }

  Future<T> create(T entity) async {
    return dio.post("/" + endpoint, data: entity).then((value) {
      return converter(value.data);
    });
  }

  Future<T> update(T entity) async {
    return dio.put("/" + endpoint, data: entity).then((value) {
      return converter(value.data);
    });
  }

  Future<ListState<T>> search(String term) async {
    return dio.get("/" + endpoint).then((value) {
      var list = (value.data as List).map((e) {
        return converter(e) as T;
      }).toList();

      return ListState(list, {});
    });
  }
}
