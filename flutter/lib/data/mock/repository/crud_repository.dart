import 'package:sudonym.models/types/list.dart';
import 'package:sudonym.models/mock/parsed_data.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../repository/crud_repository.dart' as real;

// ignore: camel_case_types
abstract class crud_repository<T> extends real.crud_repository<T> {
  List<T> data = [];

  crud_repository() {
   print(Mockdata.getData(endpoint));
  }
  @override
  Future<T> create() async {
    // TODO: implement create
    throw UnimplementedError();
  }

  @override
  Future<ListState<T>> list() async {
    return ListState(data, {});
  }

  @override
  Future<T> update() async {
    // TODO: implement update
    throw UnimplementedError();
  }

}