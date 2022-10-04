import 'dart:convert';
import 'package:sudonym.models/mock/data.dart';
import 'package:sudonym.models/index.dart' as Model;

final data = jsonDecode(json);

class Mockdata {
  static List<T> getData<T extends dynamic>(String endpoint) {
    final List<T> list = [];
    switch (endpoint) {
      case "transaction":
        data["transaction"]["mocks"].forEach((obj) {
          list.add(Model.Transaction.fromJson(obj) as T);
        });
        break;
      case "pot":
        data["pot"]["mocks"].forEach((obj) {
          list.add(Model.Pot.fromJson(obj) as T);
        });
        break;
      case "user":
        data["user"]["mocks"].forEach((obj) {
          list.add(Model.User.fromJson(obj) as T);
        });
        break;
      case "contact":
        data["contact"]["mocks"].forEach((obj) {
          list.add(Model.Contact.fromJson(obj) as T);
        });
        break;
      case "boltCard":
        data["boltCard"]["mocks"].forEach((obj) {
          list.add(Model.BoltCard.fromJson(obj) as T);
        });
        break;
    }
    return list;
  }
}
