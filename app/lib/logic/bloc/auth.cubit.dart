import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/user.dart';
import 'package:sudonym/data/repository/auth.repository.dart';
import 'package:sudonym/data/repository/user.repository.dart';
import 'package:sudonym/data/repository/websocket.dart';

@singleton
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final Websocket websocket;

  AuthCubit(this._authRepository, this._userRepository, this.websocket)
      : super(LoadedState(null)) {
    _authRepository.onStateChanged().listen((event) {
      if (event == null) {
        websocket.connect();
      } else {
        websocket.connect();
      }
    });

    _userRepository.updated.stream.listen((event) {
      if (state.user != null) {
        if (event.id == state.user!.id) {
          setUser(event);
        }
      }
    });
  }

  User? get user => state.user;

  loginWithGoogle() async {
    emit(LoadingState());
    var user = await _authRepository.loginWithGoogle();
    emit(LoadedState(await _userRepository
        .create({'id': user.user!.uid, 'firebaseId': user.user!.uid})));
  }

  loginWithFacebook() async {
    emit(LoadingState());
    var user = await _authRepository.loginWithFacebook();
    emit(LoadedState(await _userRepository
        .create({'id': user.user!.uid, 'firebaseId': user.user!.uid})));
  }

  setUser(User u) {
    emit(LoadedState(u));
  }

  logout() async {
    emit(LoadedState(null));
  }
}

abstract class AuthState {
  final User? user;
  AuthState(this.user);
}

class LoadingState extends AuthState {
  LoadingState() : super(null);
}

class LoadedState extends AuthState {
  LoadedState(User? user) : super(user);

  @override
  List<User?> get props => [user];
}

class ErrorState extends AuthState {
  ErrorState() : super(null);
}
