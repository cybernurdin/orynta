// Drives the local-accounts auth flow: register via the UI, confirm it
// lands on the app shell, then confirm the underlying session persistence
// that _StartupGate relies on (log out clears the session, log back in
// restores it) via the same LocalAuthService the gate reads from.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:orynta/app.dart';
import 'package:orynta/data/services/local_auth_service.dart';
import 'package:orynta/features/auth/login_screen.dart';
import 'package:orynta/features/auth/signup_screen.dart';
import 'package:orynta/features/shell/app_shell.dart';

void main() {
  testWidgets('register lands on the app shell, and session persists correctly after logout/login', (tester) async {
    SharedPreferences.setMockInitialValues({'orynta_onboarding_done': true});

    await tester.pumpWidget(const OryntaApp());
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);

    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();
    expect(find.byType(SignupScreen), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'Test Farmer');
    await tester.enterText(find.byType(TextField).at(1), 'test.farmer@example.com');
    await tester.enterText(find.byType(TextField).at(2), 'password123');
    await tester.enterText(find.byType(TextField).at(3), 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Create account'));
    await tester.pumpAndSettle();

    expect(find.byType(AppShell), findsOneWidget);

    final auth = LocalAuthService();
    expect((await auth.currentSession())?.email, 'test.farmer@example.com');

    await auth.logout();
    expect(await auth.currentSession(), isNull, reason: '_StartupGate reads this to decide Login vs AppShell on relaunch');

    final account = await auth.login(email: 'test.farmer@example.com', password: 'password123');
    expect(account.email, 'test.farmer@example.com');
    expect((await auth.currentSession())?.email, 'test.farmer@example.com');
  });
}
