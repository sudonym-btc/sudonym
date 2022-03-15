import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym/data/repository/User.repository.dart';
import 'package:sudonym/injection.dart';

import 'crud_repository.dart';
import 'package:sudonym.models/user.dart';

@dev
@Injectable(as: UserRepository, env: [Env.dev])
class MockUserRepository extends crud_repository<User> implements UserRepository {
  MockUserRepository(Dio dio) : super(dio);

  @override
  String get endpoint => "user";
}
