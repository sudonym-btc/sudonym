import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/types/list.dart';
import 'package:sudonym.models/user.dart';
import 'package:sudonym/data/repository/crud_repository.dart';

import '../../injection.dart';

@prod
@Injectable(as: UserRepository, env: [Env.prod])
class UserRepositoryImpl extends UserRepository {
  UserRepositoryImpl(Dio dio) : super(dio);

  @override
  Future<User> create() {
    // TODO: implement create
    throw UnimplementedError();
  }

  @override
  Future<ListState<User>> list() {
    // TODO: implement list
    throw UnimplementedError();
  }

  @override
  Future<User> update() {
    // TODO: implement update
    throw UnimplementedError();
  }

}

abstract class UserRepository extends crud_repository<User> {
  UserRepository(Dio dio) : super(dio);
}