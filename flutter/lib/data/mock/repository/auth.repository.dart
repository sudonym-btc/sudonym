import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym/data/repository/auth.repository.dart';

import '../../../injection.dart';

@Injectable(as: AuthRepository, env: [Env.mock])
class MockAuthRepository implements AuthRepository {
  @override
  Future<UserCredential> loginWithGoogle() async {
    return "999" as UserCredential;
  }
  @override
  Future<UserCredential> loginWithFacebook() async {
    return "999" as UserCredential;
  }
}