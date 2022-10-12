import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:nfc_manager/nfc_manager.dart';

@Injectable()
class NFCCubit extends Cubit<NFCCubitState> {
  NFCCubit() : super(NFCCubitState()) {}

  write(Uri url) async {
    emit(NFCCubitState(writing: true));
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      try {
        var x = Ndef.from(tag);
        if (x != null) {
          await x.write(NdefMessage([NdefRecord.createUri(url)]));
          emit(NFCCubitState(writing: false, success: true));
          NfcManager.instance.stopSession();
        }
      } on Error catch (e) {
        emit(NFCCubitState(writing: false, success: false, e: e));
      } catch (e) {
        print(e);
      }
    });
  }
}

class NFCCubitState {
  bool writing = false;
  bool reading = false;
  bool success = false;
  Error? e;

  NFCCubitState({
    this.writing = false,
    this.reading = false,
    this.success = false,
    this.e,
  });
}
