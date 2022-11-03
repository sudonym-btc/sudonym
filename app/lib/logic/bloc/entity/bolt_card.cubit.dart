import 'package:injectable/injectable.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym.models/index.dart';

@injectable
class BoltCardCubit
    extends EntityCubit<BoltCardRepository, BoltCardCubitState, BoltCard> {
  BoltCardCubit()
      : super(
            initialState: BoltCardCubitState(),
            stateClass: BoltCardCubitState.init);
}

class BoltCardCubitState extends EntityCubitState<BoltCard> {
  BoltCardCubitState({BoltCard? entity, bool loading = false})
      : super(entity: entity, loading: loading);

  BoltCardCubitState.init({BoltCard? entity, bool loading = false})
      : super(entity: entity, loading: loading);
}
