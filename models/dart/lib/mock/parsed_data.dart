import 'dart:convert';
import 'package:sudonym.models/mock/data.dart';
import 'package:sudonym.models/index.dart' as Model;

final data = jsonDecode(json);

class Mockdata {
  
  static getData(String endpoint) {

    switch (endpoint) {
      case "transaction": 
        return data["transaction"]["mocks"].map((obj) {
          print(obj);
          return Model.Transaction.fromJson(obj);
        });
      case "pot": 
        return data["pot"];
    }

    // print(Model.Pot());

    // data.forEach((final String key, final value) {
    //     print("Key: {{$key}} -> value: ${value}");
    //     // do with this info whatever you want
    // }); 
  }
}