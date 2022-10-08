import 'package:flutter_test/flutter_test.dart';
import 'package:sudonym/injection.dart';

void main() {
  setUpAll(() {
    configureInjection(Env.mock);
  });

  testWidgets("Auth page routes to sign in and homepage",
      (WidgetTester tester) async {
    // await tester.pumpWidget(const App());
    // // var authGate = find.byType(AuthGate);
    // expect(find.byType(SigninPage), findsOneWidget);
  });
}
