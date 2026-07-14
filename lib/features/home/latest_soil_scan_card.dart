import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/icon_circle.dart';
import '../../data/models/soil_scan.dart';
import '../scan/capture_screen.dart';
import '../scan/scan_type.dart';
import '../scan/soil_result_screen.dart';

/// The dashboard's "Latest Soil Scan" summary — a compact snapshot of the
/// most recent soil scan with a link into the full, detailed report.
class LatestSoilScanCard extends StatelessWidget {
  final SoilScan? scan;
  final dynamic strings;
  const LatestSoilScanCard({super.key, required this.scan, required this.strings});

  @override
  Widget build(BuildContext context) {
    final scan = this.scan;
    if (scan == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const IconCircle(icon: Icons.grass_rounded, background: AppColors.forest),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(strings('latestSoilScan'), style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                      'Scan your soil to see it here.',
                      style: const TextStyle(color: AppColors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CaptureScreen(type: ScanType.soil)),
                ),
                child: const Text('Scan now'),
              ),
            ],
          ),
        ),
      );
    }

    final health = scan.healthScore.round();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(strings('latestSoilScan'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.confidenceColor(health / 100).withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$health%',
                    style: TextStyle(color: AppColors.confidenceColor(health / 100), fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _MiniStat(label: 'Region', value: scan.region)),
                Expanded(child: _MiniStat(label: strings('soilType'), value: scan.soilType.name)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _MiniStat(label: 'pH level', value: scan.phLevel.toStringAsFixed(1))),
                Expanded(child: _MiniStat(label: 'Moisture', value: '${scan.moisturePercent.round()}%')),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => SoilResultScreen(scan: scan)),
                ),
                child: const Text('View full scan report'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }
}
