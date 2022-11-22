import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:sudonym/config/logger.dart';
import 'package:sudonym/logic/index.dart';

@singleton
class NFCListener extends TransactionListenerSubtype with NFCLogger {
  listen() {
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
    }).then((value) => loggy.i('done'));
  }

  init() async {
    if (!Platform.isIOS) {
      if (await NfcManager.instance.isAvailable()) {
        listen();
      }
    }
  }

  void dispose() {
    NfcManager.instance.stopSession();
  }
}
