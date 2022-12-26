import 'package:dio/dio.dart';
import 'package:sudonym/config/index.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym.models/mock/parsed_data.dart';

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

  beforeCreate(dynamic entity) {
    return entity;
  }

  @override
  Future<T> create(Map<String, dynamic> entity) async {
    beforeCreate(entity);
    T newEntity = converter(entity);
    var sorted = availableData.map((dynamic e) => e.id).toList();
    sorted.sort();
    (newEntity as dynamic).id = sorted.isNotEmpty
        ? (isNumType(sorted.last.runtimeType) ? sorted.last + 1 : 'random')
        : 1;
    availableData.add(newEntity);
    created.add(CreatedOrUpdated(newEntity, true, [], {}));
    return newEntity;
  }

  isNumType(dynamic t) {
    return t == num || t == int;
  }

  @override
  Future<T> fetch(dynamic id) async {
    await Future.delayed(requestDelay);
    return availableData.firstWhere((dynamic e) => e!.id == id);
  }

  @override
  Future<ListState<T>> list(
      {Map<String, dynamic>? where,
      List<List<String>>? order,
      int limit = 10}) async {
    await Future.delayed(requestDelay);
    return ListState(
        availableData.where((element) {
          if (where == null) {
            return true;
          } else {
            return where.keys.every((key) {
              if (key.contains('\$')) {
                //todo cant order by keys of child elements
                return true;
              }
              var obj = element.toJson()[key];

              if (where[key].runtimeType == int) {
                return obj == where[key];
              }
              if (where[key]['gt'] != null) {
                return obj > where[key]['gt'];
              }
              if (where[key]['lt'] != null) {
                return obj < where[key]['lt'];
              }
              return false;
            });
          }
        }).toList(),
        {});
  }

  @override
  Future<T> update(Map<String, dynamic> entity) async {
    await Future.delayed(requestDelay);
    return availableData
        .firstWhere((e) => (e as dynamic).id == (entity as dynamic)['id']);
  }

  @override
  Future<ListState<T>> search(String term) async {
    await Future.delayed(requestDelay);
    return ListState(availableData, {});
  }
}
