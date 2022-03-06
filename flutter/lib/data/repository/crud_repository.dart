import 'package:http/http.dart' as http;
import 'package:sudonym.models/types/list.dart';
const apiEndpoint = "http://localhost";

abstract class crud_repository<T> {
    String endpoint = "";
    Function converter = <T>(obj) {};

    Future<T> fetch(String id) {
      return http.get(Uri.parse(apiEndpoint + '/' + endpoint + "/" + id)).then((value) => converter(value.body));
    }
    Future<ListState<T>> list();
    Future<T> create();
    Future<T> update();
}