import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:injectable/injectable.dart';

import 'clipboard-listener.dart';

@injectable
class LinkListener extends TransactionListenerSubtype {
  StreamSubscription? _s;

  init() async {
    final appLinks = AppLinks();

// Get the initial/first link.
// This is useful when app was terminated (i.e. not started)
    final uri = await appLinks.getInitialAppLink();
    if (uri != null) {
      streamController.add(uri.toString());
    }

    appLinks.uriLinkStream.listen((e) {
      streamController.add(e.toString());
    });
  }

  void dispose() {
    _s!.cancel();
  }
}
