import 'package:flutter_test/flutter_test.dart';
import 'package:sudonym/injection.dart';

// import 'package:app/main.dart';

void main() {
  setUpAll(() {
    configureInjection(Env.mock);
  });
}
