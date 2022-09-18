import 'package:injectable/injectable.dart';

import '../injection.dart';

@Injectable(as: Config, env: [Env.mock])
class MockConfig implements Config {
  @override
  String apiUrl = 'http://10.0.2.2'; // This is the host IP for Flutter
  @override
  num apiPort = 3000;
  @override
  num websocketPort = 3000;
}

@dev
@Injectable(as: Config, env: [Env.dev])
class DevConfig implements Config {
  @override
  String apiUrl = 'https://api.local.development';
  @override
  num apiPort = 443;
  @override
  num websocketPort = 443;
}

@test
@Injectable(as: Config, env: [Env.test])
class TestConfig implements Config {
  @override
  String apiUrl = 'https://test.sudonym.app';
  @override
  num apiPort = 443;
  @override
  num websocketPort = 443;
}

@prod
@Injectable(as: Config, env: [Env.prod])
class ProdConfig implements Config {
  @override
  String apiUrl = 'http://10.0.2.2';
  @override
  num apiPort = 3000;
  @override
  num websocketPort = 3000;
}

abstract class Config {
  String apiUrl;
  num apiPort;
  num websocketPort;

  Config(this.apiUrl, this.apiPort, this.websocketPort);
}
