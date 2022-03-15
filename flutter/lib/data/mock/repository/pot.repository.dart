import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/pot.dart';
import 'package:sudonym/data/repository/pot.repository.dart';

import '../../../injection.dart';
import 'crud_repository.dart';

@dev
@Injectable(as: PotRepository, env: [Env.dev])
class MockPotRepository extends crud_repository<Pot> implements PotRepository {
  MockPotRepository(Dio dio) : super(dio);

  @override
  String get endpoint => "pot";

  @override
  getInvoice(id, type, amount) {
    // TODO: implement getInvoice
    throw UnimplementedError();
  }
}