import 'dart:async';

import 'package:clipboard/clipboard.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym/data/index.dart';

@singleton
class ClipboardListener extends TransactionListenerSubtype {
  Timer? clipboardTriggerTime;

  StreamController controller = StreamController();

  init() {
    clipboardTriggerTime =
        Timer.periodic(const Duration(seconds: 1), (timer) => check());

    controller.stream.distinct().listen((event) {
      streamController.add(event);
    });
  }

  Future<String?> check() {
    return FlutterClipboard.controlV().then((value) {
      if (value?.text != null && isValidAddress(value.text)) {
        controller.add(value.text as String);
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
  StreamController<String> streamController =
      StreamController<String>.broadcast();
}
