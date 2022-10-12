import 'package:injectable/injectable.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:sudonym/config/logger.dart';
import 'package:sudonym/logic/index.dart';

@injectable
class NFCListener extends TransactionListenerSubtype with NFCLogger {
  init() async {
    if (await NfcManager.instance.isAvailable()) {
      loggy.d('Starting NFC');
      // Start Session
      NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
        var x = Ndef.from(tag);
        for (var t in x!.cachedMessage!.records) {
          Record r = Record.fromNdef(t);
          loggy.d(r);
          if (r is WellknownUriRecord) {
            streamController.add(r.uri.toString());
          }
        }
      }).then((value) => print('done'));
    }
  }

  void dispose() {
    NfcManager.instance.stopSession();
  }
}
