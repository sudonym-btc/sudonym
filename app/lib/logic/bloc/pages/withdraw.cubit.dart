import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/data/index.dart';

@injectable
class WithdrawCubit extends Cubit<WithdrawCubitState> {
  final ActionRepository _actionRepository;

  WithdrawCubit(this._actionRepository) : super(WithdrawCubitState());

  getInfo(Withdraw p) async {
    emit(WithdrawCubitState(loadingInfo: true));
    var data =
        await Task(() => _actionRepository.getWithdrawInfo(p)).attempt().run();
    if (!isClosed) {
      emit(WithdrawCubitState(loadingInfo: false, infoData: data));
    }
  }

  withdraw(Withdraw w) async {
    emit(WithdrawCubitState(loadingWithdraw: true));
    print("WITHDRAWING");
    var data = await Task(() => _actionRepository.withdraw(w)).attempt().run();
    if (!isClosed) {
      emit(WithdrawCubitState(loadingWithdraw: false, receiverData: data));
    }
  }
}

class WithdrawCubitState {
  bool loadingInfo = false;
  bool loadingWithdraw = false;
  Either<Object, Receiver>? receiverData;
  Either<Object, Withdraw>? infoData;
  bool completed = false;

  WithdrawCubitState(
      {this.loadingInfo = false,
      this.loadingWithdraw = false,
      this.receiverData,
      this.infoData,
      this.completed = false});
}
