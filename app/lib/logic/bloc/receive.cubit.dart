import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/data/mock/repository/crud_repository.dart';
import 'package:sudonym/data/repository/receive.repository.dart';

@injectable
class ReceiveCubit extends Cubit<ReceiveCubitState> {
  final ReceiveRepository _receiveRepository;

  ReceiveCubit(this._receiveRepository) : super(ReceiveCubitState());

  getInvoice(potId, type, amount) async {
    emit(ReceiveCubitState(loading: true));
    await Future.delayed(requestDelay);
    var data = await _receiveRepository.getInvoice(potId, type, amount);
    emit(ReceiveCubitState(loading: false, data: data));
  }
}

class ReceiveCubitState {
  bool loading = false;
  Receiver? data;

  ReceiveCubitState({this.loading = false, this.data});
}
