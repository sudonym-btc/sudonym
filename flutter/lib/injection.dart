import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

final getIt = GetIt.instance;

@injectableInit
void configureInjection(String environment) {
  $initGetIt(getIt, environment: environment);
}

abstract class Env {
  static const mock = 'mock';
  static const dev = 'dev';
  static const staging = 'staging';
  static const prod = 'prod';
  static const allButMock = [Env.dev, Env.staging, Env.prod];
}
