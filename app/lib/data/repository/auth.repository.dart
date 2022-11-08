import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym/injection.dart';

@Injectable(as: AuthRepository, env: Env.allButMock)
class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<UserCredential?> loginWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null;
    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Future<UserCredential?> loginWithFacebook() async {
    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login();
    if (loginResult.status != LoginStatus.success) return null;
    // Create a credential from the access token
    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.token);

    // Once signed in, return the UserCredential
    return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  }

  @override
  Stream<User?> onStateChanged() {
    return FirebaseAuth.instance.authStateChanges();
  }

  @override
  logout() {
    return FirebaseAuth.instance.signOut();
  }
}

abstract class AuthRepository {
  Future<UserCredential?> loginWithGoogle();
  Future<UserCredential?> loginWithFacebook();
  Future logout();
  Stream<User?> onStateChanged();
  // Future<UserCredential> loginWithTwitter();
}
