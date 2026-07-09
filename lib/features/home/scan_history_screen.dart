import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/services/app_repository.dart';
import 'recent_scan_tile.dart';

/// FR-1.6: "save scans per plot; show trend over time" — this is the
/// full, unbounded list behind Home's 5-item preview, so scans can be
/// reviewed and removed instead of only ever accumulating.
class ScanHistoryScreen extends StatelessWidget {
  const ScanHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LocaleProvider>().strings;
    final repo = context.watch<AppRepository>();

    final items = <RecentScanItem>[
      ...repo.soilScans.map((s) => RecentScanItem.soil(s)),
      ...repo.leafDiagnoses.map((d) => RecentScanItem.leaf(d)),
    ]..sort((a, b) => b.capturedAt.compareTo(a.capturedAt));

    return Scaffold(
      appBar: AppBar(title: Text(strings('allScansTitle'))),
      body: items.isEmpty
          ? Center(
              child: Text(strings('noScansYet'), style: const TextStyle(color: AppColors.grey)),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: items.map((item) => RecentScanTile(item: item, strings: strings)).toList(),
            ),
    );
  }
}
