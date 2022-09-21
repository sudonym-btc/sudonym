import 'package:injectable/injectable.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:sudonym/logic/index.dart';

import 'clipboard-listener.dart';

@injectable
class NFCListener extends TransactionListenerSubtype {
  init() async {
    if (await NfcManager.instance.isAvailable()) {
      print("starting NFC");
      // Start Session
      NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
        var x = Ndef.from(tag);
        for (var t in x!.cachedMessage!.records) {
          Record r = Record.fromNdef(t);
          print(r);
          if (r is WellknownUriRecord) {
            streamController.add(r.uri.toString());
          }
        }
      });
    }
  }

  void dispose() {
    NfcManager.instance.stopSession();
  }
}
