import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:nfc_manager/nfc_manager.dart';

import 'clipboard-listener.dart';

@injectable
class NFCListener extends TransactionListenerSubtype {
  init() {
    // Start Session
    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        // Do something with an NfcTag instance.
        streamController.add(tag.data.toString());
      },
    );
  }

  void dispose() {
    NfcManager.instance.stopSession();
  }
}
