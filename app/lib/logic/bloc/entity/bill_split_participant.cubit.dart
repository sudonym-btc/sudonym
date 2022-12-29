import 'package:injectable/injectable.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym.models/index.dart';

@injectable
class BillSplitParticipantCubit extends EntityCubit<
    BillSplitParticipantRepository,
    BillSplitParticipantCubitState,
    BillSplitParticipant> {
  BillSplitParticipantCubit()
      : super(
            initialState: BillSplitParticipantCubitState(),
            stateClass: BillSplitParticipantCubitState.init);
}

class BillSplitParticipantCubitState
    extends EntityCubitState<BillSplitParticipant> {
  BillSplitParticipantCubitState(
      {BillSplitParticipant? entity, bool loading = false})
      : super(entity: entity, loading: loading);

  BillSplitParticipantCubitState.init(
      {BillSplitParticipant? entity, bool loading = false})
      : super(entity: entity, loading: loading);
}
