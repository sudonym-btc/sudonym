import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym/injection.dart';
import 'package:twitter_login/twitter_login.dart';

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
  Future<UserCredential?> loginWithTwitter() async {
    // Create a TwitterLogin instance
    final twitterLogin = TwitterLogin(
        apiKey: 'REDACTED',
        apiSecretKey: 'REDACTED',
        redirectURI: 'sudonym://');

    // Trigger the sign-in flow
    final authResult = await twitterLogin.loginV2(forceLogin: true);

    switch (authResult.status!) {
      case TwitterLoginStatus.loggedIn:
        // Create a credential from the access token
        final twitterAuthCredential = TwitterAuthProvider.credential(
          accessToken: authResult.authToken!,
          secret: authResult.authTokenSecret!,
        );

        // Once signed in, return the UserCredential
        return await FirebaseAuth.instance
            .signInWithCredential(twitterAuthCredential);
      case TwitterLoginStatus.cancelledByUser:
        return null;
      case TwitterLoginStatus.error:
        throw authResult;
    }
  }

  @override
  Future<UserCredential?> loginWithApple() async {
    // Create a TwitterLogin instance
    final twitterLogin = TwitterLogin(
        apiKey: 'REDACTED',
        apiSecretKey: 'REDACTED',
        redirectURI: '<your_scheme>://');

    // Trigger the sign-in flow
    final authResult = await twitterLogin.login();

    // Create a credential from the access token
    final twitterAuthCredential = TwitterAuthProvider.credential(
      accessToken: authResult.authToken!,
      secret: authResult.authTokenSecret!,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance
        .signInWithCredential(twitterAuthCredential);
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
  Future<UserCredential?> loginWithTwitter();
  Future<UserCredential?> loginWithApple();
  Future logout();
  Stream<User?> onStateChanged();
}
