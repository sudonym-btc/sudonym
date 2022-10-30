import 'dart:async';

import 'package:clipboard/clipboard.dart';
import 'package:injectable/injectable.dart';

@injectable
class ClipboardListener extends TransactionListenerSubtype {

  Timer? clipboardTriggerTime;

  init() {
    clipboardTriggerTime =
        Timer.periodic(const Duration(seconds: 5), (timer) => check());
  }

  Future<String?> check() {
    return FlutterClipboard.controlV().then((value) {
       if (value!.text != null) {
        streamController.add(value.text as String);
        return value.text;
      }
       return null;
    });
  }

  void dispose() {
    clipboardTriggerTime!.cancel();
  }
}

class TransactionListenerSubtype {
  StreamController<String> streamController = StreamController<String>.broadcast(); 
}