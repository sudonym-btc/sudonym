import 'package:injectable/injectable.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym.models/index.dart';

@injectable
class SenderCubit
    extends EntityCubit<SenderRepository, SenderCubitState, Sender> {
  SenderCubit()
      : super(
            initialState: SenderCubitState(),
            stateClass: SenderCubitState.init);
}

class SenderCubitState extends EntityCubitState<Sender> {
  SenderCubitState({Sender? entity, bool loading = false})
      : super(entity: entity, loading: loading);

  SenderCubitState.init({Sender? entity, bool loading = false})
      : this(entity: entity, loading: loading);
}
