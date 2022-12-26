import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym.models/index.dart';

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
        websocket.forceReconnect();
        setUser(
            await _userRepository
                .create({'id': event.uid, 'firebaseId': event.uid}),
            event);
      }
    });

    userSub = _userRepository.updated.stream.listen((event) {
      if (state.user != null) {
        if (event.entity.id == state.user!.id) {
          setUser(event.entity, state.firebaseUser!);
        }
      }
    });
  }

  User? get user => state.user;

  loginWithGoogle() async {
    emit(LoadingState());
    try {
      fb.UserCredential? response = await _authRepository.loginWithGoogle();
      if (response == null) {
        emit(LoadedState(null, null));
      }
    } catch (e) {
      emit(ErrorState(e.toString()));
    }
  }

  loginWithTwitter() async {
    emit(LoadingState());
    try {
      fb.UserCredential? response = await _authRepository.loginWithTwitter();
      if (response == null) {
        emit(LoadedState(null, null));
      }
    } catch (e) {
      emit(ErrorState(e.toString()));
    }
  }

  loginWithFacebook() async {
    emit(LoadingState());
    try {
      fb.UserCredential? response = await _authRepository.loginWithFacebook();
      if (response == null) {
        emit(LoadedState(null, null));
      }
    } catch (e) {
      emit(ErrorState(e.toString()));
    }
  }

  setUser(User? u, fb.User? fbUser) {
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
  final fb.User? firebaseUser;
  final String? error;
  AuthState(this.user, this.firebaseUser, this.error);
}

class LoadingState extends AuthState {
  LoadingState() : super(null, null, null);
}

class LoadedState extends AuthState {
  LoadedState(User? user, fb.User? firebaseUser)
      : super(user, firebaseUser, null);

  List<User?> get props => [user];
}

class ErrorState extends AuthState {
  ErrorState(String error) : super(null, null, error);
}
