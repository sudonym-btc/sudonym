import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym/config/index.dart';
import 'package:sudonym/logic/index.dart';

@singleton
class LinkListener extends TransactionListenerSubtype with ActionLogger {
  StreamSubscription? _s;

  init() async {
    final appLinks = AppLinks();

// Get the initial/first link.
// This is useful when app was terminated (i.e. not started)
    final uri = await appLinks.getInitialAppLink();
    loggy.v('initial link $uri');
    if (uri != null && !kIsWeb) {
      streamController.add(uri.toString());
    }

    _s = appLinks.uriLinkStream.listen((e) {
      streamController.add(e.toString());
    });
  }

  void dispose() {
    _s!.cancel();
  }
}
