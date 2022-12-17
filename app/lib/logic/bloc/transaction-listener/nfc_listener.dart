import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:sudonym/config/logger.dart';
import 'package:sudonym/logic/index.dart';
import 'package:universal_io/io.dart';

@singleton
class NFCListener extends TransactionListenerSubtype with NFCLogger {
  Future<void> handleTag(NfcTag tag) async {
    var x = Ndef.from(tag);
    for (var t in x!.cachedMessage!.records) {
      Record r = Record.fromNdef(t);
      loggy.d(r);
      if (r is WellknownUriRecord) {
        streamController.add(r.uri.toString());
      }
    }
    NfcManager.instance.stopSession(alertMessage: 'Found tag');
  }

  listen() async {
    loggy.d('Starting NFC');
    // Start Session
    NfcManager.instance.startSession(onDiscovered: handleTag);
  }

  init() async {
    if (!Platform.isIOS &&
        !Platform.isMacOS &&
        !Platform.isWindows &&
        !Platform.isLinux &&
        !kIsWeb) {
      if (await NfcManager.instance.isAvailable()) {
        listen();
      }
    }
  }

  void dispose() {
    NfcManager.instance.stopSession();
  }
}
