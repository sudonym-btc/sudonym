import 'package:app_links/app_links.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym/config/logger.dart';
import 'package:sudonym/logic/index.dart';

@injectable
class TransactionListenerCubit extends Cubit<TransactionListenerCubitState>
    with ActionLogger {
  ClipboardListener clipboard = ClipboardListener();
  LinkListener link = LinkListener();
  NFCListener nfc = NFCListener();

  TransactionListenerCubit() : super(TransactionListenerCubitState()) {
    listen();
    link.init();
    nfc.init();
  }

  listen() async {
    link.streamController.stream.listen((event) {
      parseAddress(event);
    });

    clipboard.streamController.stream.listen((event) {
      parseAddress(event);
    });

    nfc.streamController.stream.listen((event) {
      parseAddress(event);
    });
  }

  void parseAddress(String address) {
    loggy.info('Detected $address');
    if (!state.ignoredAddresses.contains(address)) {
      emit(TransactionReady(
          address: address, ignoredAddresses: state.ignoredAddresses));
      // ignoreAddress(address);
    }
  }

  void ignoreAddress(String address) {
    emit(TransactionListenerCubitState(
        ignoredAddresses: [...state.ignoredAddresses, address]));
  }
}

class TransactionListenerCubitState {
  String? address;
  List<String> ignoredAddresses = [];
  TransactionListenerCubitState(
      {this.ignoredAddresses = const [], this.address = null});
}

class TransactionReady extends TransactionListenerCubitState {
  String? address;
  TransactionReady({required this.address, ignoredAddresses})
      : super(ignoredAddresses: ignoredAddresses);
}
