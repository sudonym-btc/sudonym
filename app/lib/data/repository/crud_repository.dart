import 'package:dio/dio.dart';
import 'package:sudonym.models/types/list.dart';
import 'package:sudonym/data/repository/websocket.dart';

const apiEndpoint = "http://localhost";

abstract class crud_repository<T> {
  String endpoint = "";
  Function converter = <T>(obj) {};
  Dio dio;
  Websocket websocket;
  Stream<T> updated = Stream<T>.empty();
  Stream<T> created = Stream<T>.empty();

  crud_repository(this.dio, this.websocket) {
    onInit();
  }

  onInit() {}

  Future<T> fetch(String id) async {
    return dio.get("/" + endpoint + "/" + id).then((value) {
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
