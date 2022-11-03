import 'package:injectable/injectable.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym.models/index.dart';

@injectable
class UserCubit extends EntityCubit<UserRepository, UserCubitState, User> {
  UserCubit()
      : super(initialState: UserCubitState(), stateClass: UserCubitState.init);
}

class UserCubitState extends EntityCubitState<User> {
  UserCubitState({User? entity, bool loading = false})
      : super(entity: entity, loading: loading);

  UserCubitState.init({User? entity, bool loading = false})
      : super(entity: entity, loading: loading);
}
