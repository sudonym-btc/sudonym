import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/user.dart';

@injectable
class UserCubit extends Cubit<User> {
  UserCubit() : super(User({}));
}
