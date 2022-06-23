import 'package:injectable/injectable.dart';

import '../injection.dart';

@Injectable(as: Config, env: [Env.mock])
class MockConfig implements Config {
  @override
  String apiUrl = 'http://nevercalled.com';
}

@dev
@Injectable(as: Config, env: [Env.dev])
class DevConfig implements Config {
  @override
  String apiUrl = 'http://10.0.2.2:3000';
}

@prod
@Injectable(as: Config, env: [Env.prod])
class ProdConfig implements Config {
  @override
  String apiUrl = 'http://10.0.2.2:3000';
}

abstract class Config {
  String apiUrl;

  Config(this.apiUrl);
}
