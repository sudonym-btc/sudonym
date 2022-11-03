import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym.models/index.dart';

@injectable
class ActionLoader {
  final ActionRepository _actionRepository = getIt<ActionRepository>();
  final String address;
  ActionLoader(this.address);

  Future<Either<Object, ActionParseResponse>> parse() {
    return Task(() => _actionRepository.parse(address)).attempt().run();
  }
}

abstract class ActionManager<T extends ActionTypeWithAmount> {
  final ActionRepository actionRepository = getIt<ActionRepository>();

  static bool canChangeAmount() => false;

  info(T action);
  execute(T action);
}
