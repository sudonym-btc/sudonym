import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/data/repository/pay.repository.dart';

@injectable
class SendCubit extends Cubit<SendCubitState> {
  final PayRepository _payRepository;

  SendCubit(this._payRepository) : super(SendCubitState());

  getInfo(Payment p) async {
    emit(SendCubitState(loadingInfo: true));
    var data = await Task(() => _payRepository.getInfo(p)).attempt().run();
    if (!isClosed) {
      emit(SendCubitState(loadingInfo: false, infoData: data));
    }
  }

  pay(Payment p) async {
    emit(SendCubitState(loadingSend: true));
    print("PAYING");
    print(p.toJson());
    var data = await Task(() => _payRepository.pay(p)).attempt().run();
    if (!isClosed) {
      emit(SendCubitState(loadingSend: false, transactionData: data));
    }
  }
}

class SendCubitState {
  bool loadingInfo = false;
  bool loadingSend = false;
  Either<Object, Transaction>? transactionData;
  Either<Object, Payment>? infoData;
  bool completed = false;

  SendCubitState(
      {this.loadingInfo = false,
      this.loadingSend = false,
      this.transactionData = null,
      this.infoData = null,
      this.completed = false});
}
