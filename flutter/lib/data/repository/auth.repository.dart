import 'package:injectable/injectable.dart';
import 'package:sudonym/injection.dart';

@prod
@Injectable(as: AuthRepository, env: [Env.prod])
class AuthRepositoryImpl implements AuthRepository {
  @override
  String loginWithGoogle() {
    return "123";
  }
}

abstract class AuthRepository {
  String loginWithGoogle();
}