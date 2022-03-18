import 'package:injectable/injectable.dart';

import '../../injection.dart';

@Injectable(as: AuthRepository, env: Env.allButMock)
class AuthRepositoryImpl implements AuthRepository {
  @override
  String loginWithGoogle() {
    return "123";
  }
}

abstract class AuthRepository {
  String loginWithGoogle();
}