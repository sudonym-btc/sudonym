import 'dart:async';

import 'package:clipboard/clipboard.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym/data/index.dart';
import 'package:universal_io/io.dart';

@singleton
class ClipboardListener extends TransactionListenerSubtype {
  Timer? clipboardTriggerTime;

  StreamController controller = StreamController.broadcast();
  StreamSubscription? sub;

  init() {
    // Only listen to clipboard constantly if doesn't trigger notification
    if (canReadClipboardUndetected()) {
      clipboardTriggerTime = Timer.periodic(const Duration(seconds: 1),
          (timer) => check().then((text) => controller.add(text)));
    }

    sub ??= controller.stream.distinct().listen((event) {
      streamController.add(event);
    });
  }

  Future<String?> check() {
    return FlutterClipboard.controlV().then((value) {
      if (value?.text != null && isValidAddress(value!.text)) {
        return value.text;
      }
      return null;
    });
  }

  bool canReadClipboardUndetected() {
    if (Platform.isIOS) {
      return false;
    }
    return true;
  }

  void dispose() {
    clipboardTriggerTime!.cancel();
    if (sub != null) {
      sub!.cancel();
    }
  }
}

class TransactionListenerSubtype {
  StreamController<String> streamController =
      StreamController<String>.broadcast();
}
