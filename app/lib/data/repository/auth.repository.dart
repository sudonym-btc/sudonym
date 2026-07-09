import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:sudonym/injection.dart';
import 'package:twitter_login/twitter_login.dart';

@Injectable(as: AuthRepository, env: Env.allButMock)
class AuthRepositoryImpl implements AuthRepository {
  TwitterLogin _twitterLogin() {
    const apiKey = String.fromEnvironment('TWITTER_API_KEY');
    const apiSecretKey = String.fromEnvironment('TWITTER_API_SECRET_KEY');
    const redirectUri = String.fromEnvironment('TWITTER_REDIRECT_URI');

    if (apiKey.isEmpty || apiSecretKey.isEmpty || redirectUri.isEmpty) {
      throw StateError(
        'Twitter login requires TWITTER_API_KEY, '
        'TWITTER_API_SECRET_KEY, and TWITTER_REDIRECT_URI.',
      );
    }

    return TwitterLogin(
      apiKey: apiKey,
      apiSecretKey: apiSecretKey,
      redirectURI: redirectUri,
    );
  }

  @override
  Future<UserCredential?> loginWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null;
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Future<UserCredential?> loginWithTwitter() async {
    final authResult = await _twitterLogin().loginV2(forceLogin: true);

    switch (authResult.status!) {
      case TwitterLoginStatus.loggedIn:
        final twitterAuthCredential = TwitterAuthProvider.credential(
          accessToken: authResult.authToken!,
          secret: authResult.authTokenSecret!,
        );
        return FirebaseAuth.instance.signInWithCredential(
          twitterAuthCredential,
        );
      case TwitterLoginStatus.cancelledByUser:
        return null;
      case TwitterLoginStatus.error:
        throw authResult;
    }
  }

  @override
  Future<UserCredential?> loginWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [AppleIDAuthorizationScopes.email],
    );
    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );
    return FirebaseAuth.instance.signInWithCredential(oauthCredential);
  }

  @override
  Future<UserCredential?> loginWithFacebook() async {
    final LoginResult loginResult = await FacebookAuth.instance.login();
    if (loginResult.status != LoginStatus.success) return null;
    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.token);
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
