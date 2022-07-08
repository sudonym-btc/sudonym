import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/user.dart';
import 'package:sudonym/data/repository/user.repository.dart';
import 'package:sudonym/logic/bloc/entity_cubit_state.dart';

@injectable
class UserCubit extends EntityCubit<UserCubitState, User> {
  @override
  final UserRepository repository;

  UserCubit(this.repository) : super(UserCubitState(), UserCubitState.init);
}

class UserCubitState extends EntityCubitState<User> {
  UserCubitState({User? entity = null, bool loading = false})
      : super(entity: entity, loading: loading);

  UserCubitState.init({User? entity = null, bool loading = false})
      : super(entity: entity, loading: loading);
}
