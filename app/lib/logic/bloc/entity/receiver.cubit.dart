import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym.models/index.dart';

@injectable
class ReceiverCubit
    extends EntityCubit<ReceiverRepository, ReceiverCubitState, Receiver> {
  StreamSubscription? receiveSubscription;

  ReceiverCubit()
      : super(
            initialState: ReceiverCubitState(),
            stateClass: ReceiverCubitState.init);

  @override
  listenChanges() {
    receiveSubscription ??= repository.events.stream.listen((dynamic event) {
      if (state.entity != null && event.name == 'receiver.received') {
        if (event.data['id'] == state.entity!.id ||
            event.data['parentId'] == state.entity!.id &&
                state.entity!.type == 'bolt11') {
          getInvoice(
              state.entity!.potId, state.entity!.type, state.entity!.amount);
        }
      }
    });
    super.listenChanges();
  }

  getInvoice(num potId, String type,
      [num? amount, String? currency = 'BTC']) async {
    emit(ReceiverCubitState(loading: true));
    var data = await repository.getInvoice(potId, type, amount, currency);
    set(data);
  }
}

class ReceiverCubitState extends EntityCubitState<Receiver> {
  ReceiverCubitState({Receiver? entity, bool loading = false})
      : super(entity: entity, loading: loading);

  ReceiverCubitState.init({Receiver? entity, bool loading = false})
      : super(entity: entity, loading: loading);
}
