import 'package:flutter_test/flutter_test.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/main.dart';
import 'package:sudonym/presentation/pages/signin.dart';
import 'package:sudonym/presentation/widgets/auth/auth_gate.dart';

void main() {
  setUpAll(() {
    configureInjection(Env.mock);
  });

  testWidgets("Auth page routes to sign in and homepage",
      (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    // var authGate = find.byType(AuthGate);
    expect(find.byType(SigninPage), findsOneWidget);
  });
}
