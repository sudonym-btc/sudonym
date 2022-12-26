import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:sudonym/config/index.dart';
import 'package:sudonym.models/index.dart';

@lazySingleton
@injectable
class CurrentPotService with ActionLogger {
  Pot? pot;
  StreamController potChanged = StreamController.broadcast();

  set(Pot? p) {
    loggy.d('Setting pot ${p != null ? p.id : 'null'}');
    pot = p;
    potChanged.add(pot);
  }
}
