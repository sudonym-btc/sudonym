import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/pot.dart';
import 'package:sudonym.models/types/list.dart';
import 'package:sudonym/data/repository/crud_repository.dart';

import '../../injection.dart';

@prod
@Injectable(as: PotRepository, env: [Env.prod])
class PotRepositoryImpl extends PotRepository {
  PotRepositoryImpl(Dio dio) : super(dio);

  @override
  Future<Pot> create() {
    // TODO: implement create
    throw UnimplementedError();
  }

  @override
  Future<ListState<Pot>> list() {
    // TODO: implement list
    throw UnimplementedError();
  }

  @override
  Future<Pot> update() {
    // TODO: implement update
    throw UnimplementedError();
  }

  @override
  String getInvoice(id, type, amount) {
    // TODO: implement getInvoice
    throw UnimplementedError();
  }

}

abstract class PotRepository extends crud_repository<Pot> {
  PotRepository(Dio dio) : super(dio);

  String getInvoice(id, type, amount);
}