import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:injectable/injectable.dart';

@injectable
class LinkListener extends TransactionListenerSubtype {
  StreamSubscription? _s;

  init() async {
    final _appLinks = AppLinks();

// Get the initial/first link.
// This is useful when app was terminated (i.e. not started)
    final uri = await _appLinks.getInitialAppLink();
    if (uri != null) {
      streamController.add(uri.toString());
    }

    _appLinks.uriLinkStream.listen((e) {
      streamController.add(e.toString());
    });
  }

  void dispose() {
    _s!.cancel();
  }
}

class TransactionListenerSubtype {
  StreamController<String> streamController =
      StreamController<String>.broadcast();
}
