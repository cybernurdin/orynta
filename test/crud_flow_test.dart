// Drives the marketplace-listing CRUD flow (create/edit/delete) and the
// recent-scan delete flow end-to-end through real widget taps/drags.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:orynta/core/localization/locale_provider.dart';
import 'package:orynta/data/models/soil_scan.dart';
import 'package:orynta/data/services/app_repository.dart';
import 'package:orynta/features/home/home_screen.dart';
import 'package:orynta/features/market/marketplace_home_screen.dart';

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
  testWidgets('create, edit, and delete a marketplace listing', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final repo = AppRepository();
    await repo.load();

    await tester.pumpWidget(_wrap(const MarketplaceHomeScreen(), repo));
    await tester.pumpAndSettle();

    await tester.tap(find.text('My listings'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Tomato');
    await tester.enterText(find.byType(TextField).at(3), '500');
    await tester.enterText(find.byType(TextField).at(4), '10');
    await tester.ensureVisible(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Tomato'), findsWidgets);
    expect(repo.myListings, hasLength(1));

    await tester.tap(find.textContaining('Tomato').first);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Maize');
    await tester.ensureVisible(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(repo.myListings.single.productName, 'Maize');

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.textContaining('Maize'), findsWidgets);
    expect(find.textContaining('Tomato'), findsNothing);

    await tester.tap(find.textContaining('Maize').first);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(repo.myListings, isEmpty);
    expect(find.text("You haven't listed anything yet."), findsOneWidget);
  });

  testWidgets('delete a soil scan via swipe on the home screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final repo = AppRepository();
    await repo.load();
    await repo.addSoilScan(SoilScan(
      id: 'scan_1',
      source: SoilScanSource.photo,
      capturedAt: DateTime.now(),
      soilType: SoilType.loam,
      fertilityBand: FertilityBand.medium,
      confidence: 0.9,
      modelVersion: 'v1',
      recommendations: const [],
    ));

    await tester.pumpWidget(_wrap(const HomeScreen(), repo));
    await tester.pumpAndSettle();

    // Target the swipeable tile by its Dismissible key rather than by the
    // text "loam" — the dashboard's Latest Soil Scan card now also shows
    // the soil type as plain text, so a text-based finder is ambiguous.
    final tile = find.byKey(const ValueKey('scan_1'));
    final homeScroll = find.byKey(const Key('homeScrollView'));
    await tester.dragUntilVisible(tile, homeScroll, const Offset(0, -200));
    await tester.pumpAndSettle();

    expect(tile, findsOneWidget);
    expect(repo.soilScans, hasLength(1));

    await tester.drag(tile, const Offset(-500, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(tile, findsNothing);
    expect(repo.soilScans, isEmpty);
  });
}
