import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as FB;
import 'package:sudonym/data/index.dart';

@singleton
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final Websocket websocket;
  StreamSubscription? authSub;
  StreamSubscription? userSub;

  AuthCubit(this._authRepository, this._userRepository, this.websocket)
      : super(LoadedState(null, null)) {
    authSub = _authRepository.onStateChanged().listen((event) async {
      if (event == null) {
        websocket.disconnect();
        setUser(null, null);
      } else {
        setUser(null, event);
        websocket.connect();
        setUser(
            await _userRepository
                .create({'id': event.uid, 'firebaseId': event.uid}),
            event);
      }
    });

    userSub = _userRepository.updated.stream.listen((event) {
      if (state.user != null) {
        if (event.id == state.user!.id) {
          setUser(event, state.firebaseUser!);
        }
      }
    });
  }

  User? get user => state.user;

  loginWithGoogle() async {
    emit(LoadingState());
    await _authRepository.loginWithGoogle();
  }

  loginWithFacebook() async {
    emit(LoadingState());
    await _authRepository.loginWithFacebook();
  }

  setUser(User? u, FB.User? fbUser) {
    emit(LoadedState(u, fbUser));
  }

  logout() async {
    await _authRepository.logout();
    emit(LoadedState(null, null));
  }

  @override
  Future<void> close() async {
    await userSub?.cancel();
    await authSub?.cancel();
    return super.close();
  }
}

abstract class AuthState {
  final User? user;
  final FB.User? firebaseUser;
  AuthState(this.user, this.firebaseUser);
}

class LoadingState extends AuthState {
  LoadingState() : super(null, null);
}

class LoadedState extends AuthState {
  LoadedState(User? user, FB.User? firebaseUser) : super(user, firebaseUser);

  @override
  List<User?> get props => [user];
}

class ErrorState extends AuthState {
  ErrorState() : super(null, null);
}
