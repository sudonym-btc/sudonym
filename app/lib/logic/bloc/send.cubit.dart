import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/data/repository/pay.repository.dart';

@injectable
class SendCubit extends Cubit<SendCubitState> {
  final PayRepository _payRepository;

  SendCubit(this._payRepository) : super(SendCubitState());

  getInfo(address) async {
    emit(SendCubitState(loadingInfo: true));
    emit(SendCubitState(
        loadingInfo: false,
        infoData: await Task(() => _payRepository.getInfo(address)).attempt().run()));
  }

  pay(address) async {
    emit(SendCubitState(loadingSend: true));
    emit(SendCubitState(
        loadingSend: false,
        transactionData: await Task(() => _payRepository.pay(address)).attempt().run()));
  }
}

class SendCubitState {
  bool loadingInfo = false;
  bool loadingSend = false;
  Either<Object, Transaction>? transactionData;
  Either<Object, TransactionConfirm>? infoData;
  bool completed = false;

  SendCubitState(
      {this.loadingInfo = false,
      this.loadingSend = false,
      this.transactionData = null,
      this.infoData = null,
      this.completed = false});
}
