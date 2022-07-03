import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/data/repository/receive.repository.dart';

@injectable
class ReceiveCubit extends Cubit<ReceiveCubitState> {
  final ReceiveRepository _receiveRepository;

  ReceiveCubit(this._receiveRepository) : super(ReceiveCubitState());

  getInvoice(potId, type, [num? amount]) async {
    emit(ReceiveCubitState(loading: true));
    var data = await _receiveRepository.getInvoice(potId, type, amount);
    if (!isClosed) emit(ReceiveCubitState(loading: false, data: data));
  }
}

class ReceiveCubitState {
  bool loading = false;
  Receiver? data;

  ReceiveCubitState({this.loading = false, this.data});
}
