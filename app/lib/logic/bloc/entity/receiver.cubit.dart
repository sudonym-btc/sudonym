import 'package:injectable/injectable.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/logic/index.dart';

@injectable
class ReceiverCubit
    extends EntityCubit<ReceiverRepository, ReceiverCubitState, Receiver> {
  ReceiverCubit()
      : super(
            initialState: ReceiverCubitState(),
            stateClass: ReceiverCubitState.init);

  getInvoice(num potId, String type,
      [num? amount, String? currency = 'BTC']) async {
    emit(ReceiverCubitState(loading: true));
    var data = await repository.getInvoice(potId, type, amount, currency);
    if (!isClosed) emit(ReceiverCubitState(loading: false, entity: data));
  }
}

class ReceiverCubitState extends EntityCubitState<Receiver> {
  ReceiverCubitState({Receiver? entity, bool loading = false})
      : super(entity: entity, loading: loading);

  ReceiverCubitState.init({Receiver? entity, bool loading = false})
      : super(entity: entity, loading: loading);
}
