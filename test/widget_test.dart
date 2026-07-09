// Basic smoke test: the app boots to the onboarding screen for a
// first-time user and shows the brand tagline.
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:orynta/app.dart';

void main() {
  testWidgets('Orynta boots to onboarding for a first-time user', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const OryntaApp());
    await tester.pumpAndSettle();

    expect(find.text('ORYNTA'), findsOneWidget);
    expect(find.text('Grow smarter, farm better'), findsOneWidget);
  });
}
