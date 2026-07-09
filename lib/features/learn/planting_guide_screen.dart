import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/icon_circle.dart';
import '../../core/widgets/section_header.dart';
import '../../data/models/planting_guide_entry.dart';
import '../../data/services/planting_guide_service.dart';

/// Seasonal planting/harvest reference per crop — surfaced from Home's
/// Explore row and useful alongside a soil scan's crop recommendations.
class PlantingGuideScreen extends StatefulWidget {
  const PlantingGuideScreen({super.key});

  @override
  State<PlantingGuideScreen> createState() => _PlantingGuideScreenState();
}

class _PlantingGuideScreenState extends State<PlantingGuideScreen> {
  final PlantingGuideService _service = PlantingGuideService();
  List<PlantingGuideEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _service.getAll().then((entries) {
      if (mounted) setState(() => _entries = entries);
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LocaleProvider>().strings;

    return Scaffold(
      appBar: AppBar(title: Text(strings('plantingGuide'))),
      body: _entries.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _entries.length,
              itemBuilder: (_, i) => _CropGuideCard(entry: _entries[i], strings: strings),
            ),
    );
  }
}

class _CropGuideCard extends StatelessWidget {
  final PlantingGuideEntry entry;
  final dynamic strings;
  const _CropGuideCard({required this.entry, required this.strings});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        shape: const Border(),
        leading: const IconCircle(icon: Icons.eco_rounded, background: AppColors.forest),
        title: Text(entry.cropName, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(entry.bestPlantingSeason, style: const TextStyle(fontSize: 12, color: AppColors.grey)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          SectionHeader(title: strings('growthDuration')),
          const SizedBox(height: 6),
          Text(entry.growthDuration, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 14),
          SectionHeader(title: strings('waterNeeds')),
          const SizedBox(height: 6),
          Text(entry.waterNeeds, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 14),
          SectionHeader(title: strings('commonThreats')),
          const SizedBox(height: 6),
          Text(entry.commonThreats, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 14),
          SectionHeader(title: strings('harvestNotes')),
          const SizedBox(height: 6),
          Text(entry.harvestNotes, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
