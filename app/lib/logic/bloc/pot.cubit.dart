import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/pot.dart';

import '../../data/repository/pot.repository.dart';
import 'entity_cubit_state.dart';

@injectable
class PotCubit extends EntityCubit<PotCubitState, Pot> {
  @override
  final PotRepository repository;

  PotCubit(this.repository) : super(PotCubitState(), PotCubitState.init);
}

class PotCubitState extends EntityCubitState<Pot> {
  PotCubitState({Pot? entity = null, bool loading = false})
      : super(entity: entity, loading: loading);

  PotCubitState.init({Pot? entity = null, bool loading = false})
      : super(entity: entity, loading: loading);
}
