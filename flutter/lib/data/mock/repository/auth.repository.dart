import 'package:injectable/injectable.dart';
import 'package:sudonym/data/repository/auth.repository.dart';

import '../../../injection.dart';

@Injectable(as: AuthRepository, env: [Env.mock])
class MockAuthRepository implements AuthRepository {
  @override
  String loginWithGoogle() {
    return "999";
  }
}