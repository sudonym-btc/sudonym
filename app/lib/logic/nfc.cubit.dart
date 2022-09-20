import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:nfc_manager/nfc_manager.dart';

@Injectable()
class NFCCubit extends Cubit<NFCCubitState> {
  NFCCubit() : super(NFCCubitState()) {}

  write(Uri url) async {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      var x = Ndef.from(tag);
      if (x != null) {
        await x.write(NdefMessage([NdefRecord.createUri(url)]));
      }
    });
  }
}

class NFCCubitState {
  bool writing = false;
  bool reading = false;
  Error? e;

  NFCCubitState({
    this.writing = false,
    this.reading = false,
    this.e,
  });
}
