// Drives the SoilLens-inspired additions end-to-end through real widget
// interactions: AgriForum post + comment, saving/removing a crop
// recommendation, the officer chat round-trip, and the notification inbox.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:orynta/core/localization/locale_provider.dart';
import 'package:orynta/data/models/saved_crop.dart';
import 'package:orynta/data/models/soil_scan.dart';
import 'package:orynta/data/services/app_repository.dart';
import 'package:orynta/features/community/forum_screen.dart';
import 'package:orynta/features/crops/my_crops_screen.dart';
import 'package:orynta/features/notifications/notifications_screen.dart';
import 'package:orynta/features/support/chat_screen.dart';

Widget _wrap(Widget child, AppRepository repo) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => LocaleProvider()..load()),
      ChangeNotifierProvider.value(value: repo),
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  testWidgets('post a question to AgriForum, open it, and add a comment', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final repo = AppRepository();
    await repo.load();

    await tester.pumpWidget(_wrap(const ForumScreen(), repo));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ask a question'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Aphids on beans');
    await tester.enterText(find.byType(TextField).at(1), 'Does anyone know a natural fix for aphids on beans?');
    await tester.tap(find.text('Post'));
    await tester.pumpAndSettle();

    expect(find.text('Aphids on beans'), findsOneWidget);

    await tester.tap(find.text('Aphids on beans').first);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Try a soapy water spray.');
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Try a soapy water spray.'), findsOneWidget);
    expect(repo.forumPosts.first.comments, hasLength(1));
  });

  testWidgets('save a crop recommendation then remove it from My Crops', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final repo = AppRepository();
    await repo.load();
    await repo.saveCrop(SavedCrop(
      id: 'saved_1',
      cropName: 'Tomato',
      rationale: 'Tomato suits loam soil.',
      savedAt: DateTime.now(),
    ));

    await tester.pumpWidget(_wrap(const MyCropsScreen(), repo));
    await tester.pumpAndSettle();

    expect(find.text('Tomato'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Tomato'), findsNothing);
    expect(repo.savedCrops, isEmpty);
  });

  testWidgets('send a chat message to the agricultural officer and get a reply', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final repo = AppRepository();
    await repo.load();

    await tester.pumpWidget(_wrap(const ChatScreen(), repo));
    await tester.pumpAndSettle();

    final initialMessageCount = repo.chatMessages.length;

    await tester.enterText(find.byType(TextField), 'My tomato leaves have brown spots.');
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();

    expect(find.text('My tomato leaves have brown spots.'), findsOneWidget);
    expect(repo.chatMessages.length, initialMessageCount + 2);
    expect(repo.unreadNotificationCount, 1);
  });

  testWidgets('mark all notifications as read', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final repo = AppRepository();
    await repo.load();
    await repo.addSoilScan(SoilScan(
      id: 'scan_notif',
      source: SoilScanSource.photo,
      capturedAt: DateTime.now(),
      soilType: SoilType.loam,
      fertilityBand: FertilityBand.medium,
      confidence: 0.9,
      modelVersion: 'v1',
      recommendations: const [],
    ));

    await tester.pumpWidget(_wrap(const NotificationsScreen(), repo));
    await tester.pumpAndSettle();

    expect(repo.unreadNotificationCount, 1);
    expect(find.text('Mark all read'), findsOneWidget);

    await tester.tap(find.text('Mark all read'));
    await tester.pumpAndSettle();

    expect(repo.unreadNotificationCount, 0);
  });
}
