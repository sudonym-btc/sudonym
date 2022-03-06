import 'package:injectable/injectable.dart';
import 'package:sudonym/data/repository/auth.repository.dart';

import '../../../injection.dart';

@dev
@Injectable(as: AuthRepository, env: [Env.dev])
class MockAuthRepository implements AuthRepository {
  @override
  String loginWithGoogle() {
    return "999";
  }
}