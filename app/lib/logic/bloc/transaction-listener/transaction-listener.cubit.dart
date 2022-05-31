import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym/logic/bloc/transaction-listener/clipboard-listener.dart';

@injectable
class TransactionListenerCubit extends Cubit<TransactionListenerCubitState> {
  ClipboardListener clipboard = ClipboardListener();

  TransactionListenerCubit() : super(TransactionListenerCubitState()) {
    // clipboard.init();
    listen();
  }

  listen() {
    clipboard.streamController.stream.listen((event) {
      parseAddress(event);
    });
  }

  void parseAddress(String address) {
    if (!state.ignoredAddresses.contains(address)) {
      emit(TransactionReady(
          address: address, ignoredAddresses: state.ignoredAddresses));
      ignoreAddress(address);
    }
  }

  void ignoreAddress(String address) {
    emit(TransactionListenerCubitState(
        ignoredAddresses: [...state.ignoredAddresses, address]));
  }
}

class TransactionListenerCubitState {
  List<String> ignoredAddresses = [];
  TransactionListenerCubitState({this.ignoredAddresses = const []});
}

class TransactionReady extends TransactionListenerCubitState {
  String address;
  TransactionReady({required this.address, ignoredAddresses})
      : super(ignoredAddresses: ignoredAddresses);
}
