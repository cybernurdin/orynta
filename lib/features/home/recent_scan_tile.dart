import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/icon_circle.dart';
import '../../data/models/leaf_diagnosis.dart';
import '../../data/models/soil_scan.dart';
import '../../data/services/app_repository.dart';

class RecentScanItem {
  final String id;
  final bool isSoil;
  final DateTime capturedAt;
  final double confidence;
  final String title;

  RecentScanItem.soil(SoilScan s)
      : id = s.id,
        isSoil = true,
        capturedAt = s.capturedAt,
        confidence = s.confidence,
        title = s.soilType.name;

  RecentScanItem.leaf(LeafDiagnosis d)
      : id = d.id,
        isSoil = false,
        capturedAt = d.capturedAt,
        confidence = d.confidence,
        title = d.predictedClass;
}

class RecentScanTile extends StatelessWidget {
  final RecentScanItem item;
  final dynamic strings;
  const RecentScanTile({super.key, required this.item, required this.strings});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.confidenceColor(item.confidence);
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.confidenceLow,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.white),
      ),
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(strings('delete')),
          content: Text(strings('deleteScanConfirm')),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(strings('cancel'))),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(strings('confirm'), style: const TextStyle(color: AppColors.confidenceLow)),
            ),
          ],
        ),
      ),
      onDismissed: (_) {
        final repo = context.read<AppRepository>();
        item.isSoil ? repo.removeSoilScan(item.id) : repo.removeLeafDiagnosis(item.id);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          leading: IconCircle(
            icon: item.isSoil ? Icons.grass_rounded : Icons.eco_rounded,
            background: item.isSoil ? AppColors.forest : AppColors.amber,
            size: 40,
          ),
          title: Text(item.title),
          subtitle: Text(
            '${item.capturedAt.year}-${item.capturedAt.month.toString().padLeft(2, '0')}-${item.capturedAt.day.toString().padLeft(2, '0')}'
            ' · ${item.capturedAt.hour.toString().padLeft(2, '0')}:${item.capturedAt.minute.toString().padLeft(2, '0')}',
          ),
          trailing: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}
