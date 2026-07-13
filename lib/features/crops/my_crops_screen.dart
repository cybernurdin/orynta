import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/icon_circle.dart';
import '../../data/services/app_repository.dart';
import 'crops_directory_screen.dart';

/// Crop recommendations the farmer bookmarked from a soil scan result,
/// kept independent of the scan itself.
class MyCropsScreen extends StatelessWidget {
  const MyCropsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LocaleProvider>().strings;
    final crops = context.watch<AppRepository>().savedCrops;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings('myCrops')),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Browse crop directory',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CropsDirectoryScreen()),
            ),
          ),
        ],
      ),
      body: crops.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  strings('noSavedCrops'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.grey),
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: crops.map(
                (c) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const IconCircle(icon: Icons.eco_rounded, background: AppColors.forest),
                    title: Text(c.cropName),
                    subtitle: Text(c.rationale, maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.confidenceLow),
                      tooltip: strings('delete'),
                      onPressed: () => context.read<AppRepository>().removeSavedCrop(c.id),
                    ),
                  ),
                ),
              ).toList(),
            ),
    );
  }
}
