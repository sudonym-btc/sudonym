import 'package:injectable/injectable.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym.models/index.dart';

@injectable
class PotCubit extends EntityCubit<PotRepository, PotCubitState, Pot> {
  PotCubit()
      : super(initialState: PotCubitState(), stateClass: PotCubitState.init);
}

class PotCubitState extends EntityCubitState<Pot> {
  PotCubitState({Pot? entity, bool loading = false})
      : super(entity: entity, loading: loading);

  PotCubitState.init({Pot? entity, bool loading = false})
      : super(entity: entity, loading: loading);
}
