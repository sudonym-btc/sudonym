import 'package:injectable/injectable.dart';
import 'package:sudonym/config/index.dart';
import 'package:sudonym.models/index.dart';

@lazySingleton
@injectable
class CurrentPotService with ActionLogger {
  Pot? pot;

  set(Pot p) {
    loggy.d('Setting pot ${p.id}');
    pot = p;
  }
}
