import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/confidence_badge.dart';
import '../../core/widgets/section_header.dart';
import '../../data/models/saved_crop.dart';
import '../../data/models/soil_scan.dart';
import '../../data/services/app_repository.dart';
import '../shell/app_shell.dart';

/// FR-1.2–1.4: soil type + fertility + confidence, never shown without
/// its confidence band, plus the ranked crop list with plain-language
/// rationale (FR-1.3).
class SoilResultScreen extends StatelessWidget {
  final SoilScan scan;
  const SoilResultScreen({super.key, required this.scan});

  String _soilTypeLabel(SoilType type) => switch (type) {
        SoilType.clay => 'Clay',
        SoilType.sandy => 'Sandy',
        SoilType.loam => 'Loam',
        SoilType.silt => 'Silt',
        SoilType.mixed => 'Mixed',
      };

  String _fertilityLabel(FertilityBand band) => switch (band) {
        FertilityBand.low => 'Low',
        FertilityBand.medium => 'Medium',
        FertilityBand.high => 'High',
      };

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LocaleProvider>().strings;
    final repo = context.watch<AppRepository>();
    final savedCropNames = repo.savedCrops.map((c) => c.cropName).toSet();

    return Scaffold(
      appBar: AppBar(title: Text(strings('scanSoilTitle'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ConfidenceBadge(confidence: scan.confidence, strings: strings),
                  const SizedBox(height: 16),
                  Text('Soil health score', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${scan.healthScore.round()}',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppColors.confidenceColor(scan.healthScore / 100),
                              fontSize: 42,
                            ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 8),
                        child: Text('/ 100', style: TextStyle(color: AppColors.grey)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(label: strings('soilType'), value: _soilTypeLabel(scan.soilType)),
                  const SizedBox(height: 10),
                  _InfoRow(label: strings('fertility'), value: _fertilityLabel(scan.fertilityBand)),
                  const SizedBox(height: 10),
                  _InfoRow(label: 'Location', value: scan.region),
                ],
              ),
            ),
          ),
          if (scan.confidence < 0.70) ...[
            const SizedBox(height: 12),
            _EscalationNotice(text: strings('escalationNotice')),
          ],
          const SizedBox(height: 20),
          SectionHeader(title: 'Soil conditions'),
          const SizedBox(height: 10),
          _MetricGrid(scan: scan),
          const SizedBox(height: 20),
          SectionHeader(title: 'Nutrient analysis'),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _NutrientBar(label: 'Nitrogen', value: scan.nitrogenPercent),
                  const SizedBox(height: 14),
                  _NutrientBar(label: 'Phosphorus', value: scan.phosphorusPercent),
                  const SizedBox(height: 14),
                  _NutrientBar(label: 'Potassium', value: scan.potassiumPercent),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SectionHeader(title: strings('recommendedCrops')),
          const SizedBox(height: 10),
          ...scan.recommendations.map(
            (rec) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.moss.withValues(alpha: 0.3),
                        child: Text(
                          '${rec.rank}',
                          style: const TextStyle(
                            color: AppColors.forest,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(rec.cropName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(
                              rec.rationale,
                              style: const TextStyle(color: AppColors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          savedCropNames.contains(rec.cropName)
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_outline_rounded,
                          color: AppColors.forest,
                        ),
                        tooltip: strings('saveToMyCrops'),
                        onPressed: savedCropNames.contains(rec.cropName)
                            ? null
                            : () => context.read<AppRepository>().saveCrop(
                                  SavedCrop(
                                    id: 'saved_${DateTime.now().microsecondsSinceEpoch}',
                                    cropName: rec.cropName,
                                    rationale: rec.rationale,
                                    savedAt: DateTime.now(),
                                  ),
                                ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                  child: Text(strings('scanAnother')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const AppShell()),
                    (route) => false,
                  ),
                  child: Text(strings('backToHome')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 14)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      ],
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.scan});

  final SoilScan scan;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricTile(
            icon: Icons.science_outlined,
            label: 'pH level',
            value: scan.phLevel.toStringAsFixed(1),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricTile(
            icon: Icons.water_drop_outlined,
            label: 'Moisture',
            value: '${scan.moisturePercent.round()}%',
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: AppColors.forest),
              const SizedBox(height: 14),
              Text(value, style: Theme.of(context).textTheme.titleLarge),
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.grey)),
            ],
          ),
        ),
      );
}

class _NutrientBar extends StatelessWidget {
  const _NutrientBar({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text('${value.round()}%', style: const TextStyle(color: AppColors.grey)),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 8,
              backgroundColor: AppColors.moss.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation(AppColors.forest),
            ),
          ),
        ],
      );
}

class _EscalationNotice extends StatelessWidget {
  final String text;
  const _EscalationNotice({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.confidenceLow.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.confidenceLow, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(color: AppColors.ink, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
