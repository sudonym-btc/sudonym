import 'package:flutter/services.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:ndef/ndef.dart' as ndef;

class NFC {
  NFCAvailability availability = NFCAvailability.not_supported;
  List<ndef.NDEFRecord>? _records;

  NFC() {
    init();
  }

  init() async {
    try {
      availability = await FlutterNfcKit.nfcAvailability;
    } on PlatformException {
      availability = NFCAvailability.not_supported;
    }
  }

  write() async {
    try {
      NFCTag tag = await FlutterNfcKit.poll();
      await FlutterNfcKit.writeNDEFRecords(_records!);
    } catch (e, stacktrace) {
      print(stacktrace);
    } finally {
      await FlutterNfcKit.finish();
    }
  }
}
