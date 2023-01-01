import 'package:injectable/injectable.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym.models/index.dart';

@injectable
class BillSplitCubit
    extends EntityCubit<BillSplitRepository, BillSplitCubitState, BillSplit> {
  BillSplitCubit()
      : super(
            initialState: BillSplitCubitState(),
            stateClass: BillSplitCubitState.init);
}

class BillSplitCubitState extends EntityCubitState<BillSplit> {
  BillSplitCubitState({BillSplit? entity, bool loading = false})
      : super(entity: entity, loading: loading);

  BillSplitCubitState.init({BillSplit? entity, bool loading = false})
      : super(entity: entity, loading: loading);
}
