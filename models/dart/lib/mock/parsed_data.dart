import 'dart:convert';
import 'package:sudonym.models/mock/data.dart';
import 'package:sudonym.models/index.dart' as Model;

final data = jsonDecode(json);

class Mockdata {
  static List<T> getData<T>(String endpoint) {
    final List<T> list = [];
    switch (endpoint) {
      case "transaction":
        data["transaction"]["mocks"].forEach((obj) {
          list.add(Model.Transaction.fromJson(obj));
        });
        break;
      case "pot":
        data["pot"]["mocks"].forEach((obj) {
          list.add(Model.Pot.fromJson(obj));
        });
        break;
      case "user":
        data["user"]["mocks"].forEach((obj) {
          list.add(Model.User.fromJson(obj));
        });
        break;
    }
    return list;
  }
}
