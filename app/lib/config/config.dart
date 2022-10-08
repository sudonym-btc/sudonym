import 'package:injectable/injectable.dart';

import 'package:sudonym/injection.dart';

@Injectable(as: Config, env: [Env.mock])
class MockConfig implements Config {
  @override
  String domain = 'mock.app';
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
  String domain = 'local.development';
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
  String domain = 'test.sudonym.app';
  @override
  String apiUrl = 'https://api.test.sudonym.app';
  @override
  num apiPort = 443;
  @override
  num websocketPort = 443;
}

@Injectable(as: Config, env: [Env.staging])
class StagingConfig implements Config {
  @override
  String domain = 'staging.sudonym.app';
  @override
  String apiUrl = 'https://api.staging.sudonym.app';
  @override
  num apiPort = 3000;
  @override
  num websocketPort = 3000;
}

@prod
@Injectable(as: Config, env: [Env.prod])
class ProdConfig implements Config {
  @override
  String domain = 'sudonym.app';
  @override
  String apiUrl = 'https://api.sudonym.app';
  @override
  num apiPort = 3000;
  @override
  num websocketPort = 3000;
}

abstract class Config {
  String domain;
  String apiUrl;
  num apiPort;
  num websocketPort;

  Config(this.domain, this.apiUrl, this.apiPort, this.websocketPort);
}
