import 'package:dio/dio.dart';
import 'package:sudonym.models/types/list.dart';
import 'package:sudonym/data/repository/websocket.dart';
import 'package:sudonym/injection.dart';

const apiEndpoint = "http://localhost";

abstract class crud_repository<T> {
  String endpoint = "";
  Function converter = <T>(obj) {};
  Dio dio;
  Stream<T> updated = Stream<T>.empty();
  Stream<T> created = Stream<T>.empty();

  crud_repository(this.dio) {
    getIt<Websocket>().getStream().listen((event) {
      print(event);
    });
    onInit();
  }

  onInit() {

  }

  Future<T> fetch(String id) {
    return dio
        .get(endpoint + "/" + id)
        .then((value) => converter(value.data));
  }

  Future<ListState<T>> list();
  Future<T> create();
  Future<T> update();
}
