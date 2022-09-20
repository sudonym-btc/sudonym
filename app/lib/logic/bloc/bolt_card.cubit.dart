import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/data/repository/bolt_card.repository.dart';

import 'entity_cubit_state.dart';

@injectable
class BoltCardCubit extends EntityCubit<BoltCardCubitState, BoltCard> {
  @override
  final BoltCardRepository repository;

  BoltCardCubit(this.repository)
      : super(BoltCardCubitState(), BoltCardCubitState.init);
}

class BoltCardCubitState extends EntityCubitState<BoltCard> {
  BoltCardCubitState({BoltCard? entity = null, bool loading = false})
      : super(entity: entity, loading: loading);

  BoltCardCubitState.init({BoltCard? entity = null, bool loading = false})
      : super(entity: entity, loading: loading);
}
