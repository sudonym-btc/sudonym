import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/user.dart';
import 'package:sudonym/data/repository/auth.repository.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  AuthCubit(this._authRepository) : super(LoadedState(null));

  loginWithGoogle() async {
    emit(LoadingState());
    var user = _authRepository.loginWithGoogle();
    emit(LoadedState(User(123, "", '', "")));
  }

  loginWithFacebook() async {
    emit(LoadingState());
    emit(LoadedState(User(123, "", '', "")));
  }

  logout() async {
    emit(LoadedState(null));
  }
}

abstract class AuthState {}

class LoadingState extends AuthState {}

class LoadedState extends AuthState {
  LoadedState(this.user);
  final User? user;
  @override
  List<User?> get props => [user];
}

class ErrorState extends AuthState {}
