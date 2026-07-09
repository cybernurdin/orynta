// Drives the market-listing CRUD flow (create/edit/delete) and the
// recent-scan delete flow end-to-end through real widget taps/drags.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:orynta/core/localization/locale_provider.dart';
import 'package:orynta/data/models/soil_scan.dart';
import 'package:orynta/data/services/app_repository.dart';
import 'package:orynta/features/home/home_screen.dart';
import 'package:orynta/features/market/market_screen.dart';

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
  testWidgets('create, edit, and delete a market listing', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final repo = AppRepository();
    await repo.load();

    await tester.pumpWidget(_wrap(const MarketScreen(), repo));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Tomato');
    await tester.enterText(find.byType(TextField).at(1), '120');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Tomato'), findsOneWidget);
    expect(repo.listings, hasLength(1));

    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Maize');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Maize'), findsOneWidget);
    expect(find.textContaining('Tomato'), findsNothing);
    expect(repo.listings.single.cropName, 'Maize');

    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Maize'), findsNothing);
    expect(find.text('You have no active listings.'), findsOneWidget);
    expect(repo.listings, isEmpty);
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

    final homeScroll = find.byKey(const Key('homeScrollView'));
    await tester.dragUntilVisible(find.text('loam'), homeScroll, const Offset(0, -200));
    await tester.pumpAndSettle();

    expect(find.text('loam'), findsOneWidget);
    expect(repo.soilScans, hasLength(1));

    await tester.drag(find.text('loam'), const Offset(-500, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(find.text('loam'), findsNothing);
    expect(repo.soilScans, isEmpty);
  });
}
