import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/data/repository/action.repository.dart';

@injectable
class SendCubit extends Cubit<SendCubitState> {
  final ActionRepository _actionRepository;

  SendCubit(this._actionRepository) : super(SendCubitState());

  getInfo(Action p) async {
    emit(SendCubitState(loadingInfo: true));
    var data = await Task(() => _actionRepository.getInfo(p)).attempt().run();
    if (!isClosed) {
      emit(SendCubitState(loadingInfo: false, infoData: data));
    }
  }

  pay(Payment p) async {
    emit(SendCubitState(loadingSend: true));
    var data = await Task(() => _actionRepository.pay(p)).attempt().run();
    if (!isClosed) {
      emit(SendCubitState(loadingSend: false, transactionData: data));
    }
  }
}

class SendCubitState {
  bool loadingInfo = false;
  bool loadingSend = false;
  Either<Object, Transaction>? transactionData;
  Either<Object, Action>? infoData;
  bool completed = false;

  SendCubitState(
      {this.loadingInfo = false,
      this.loadingSend = false,
      this.transactionData = null,
      this.infoData = null,
      this.completed = false});
}
