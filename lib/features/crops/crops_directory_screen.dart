import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/localization/locale_provider.dart';
import '../../core/widgets/crop_card.dart';
import '../../data/models/crop_data.dart';
import '../../data/models/saved_crop.dart';
import '../../data/services/app_repository.dart';

/// Fixed UI buckets requested for the Planting Recommendations filters.
/// `root_crop` and `cash_crop` (the two categories in the underlying
/// CameruCropsDatabase that don't map to one of the four named buckets)
/// fold into "Other" here — the raw `CropData.category` values on the 21
/// records themselves are untouched, only this display grouping changes.
const List<String> _categoryBuckets = ['grain', 'vegetable', 'fruit', 'legume', 'other'];

String _bucketFor(String rawCategory) => switch (rawCategory) {
      'root_crop' || 'cash_crop' => 'other',
      _ => rawCategory,
    };

class CropsDirectoryScreen extends StatefulWidget {
  const CropsDirectoryScreen({super.key});

  @override
  State<CropsDirectoryScreen> createState() => _CropsDirectoryScreenState();
}

class _CropsDirectoryScreenState extends State<CropsDirectoryScreen> {
  String _query = '';
  String? _bucket;

  String _bucketLabel(dynamic strings, String bucket) => switch (bucket) {
        'grain' => strings('categoryGrains'),
        'vegetable' => strings('categoryVegetables'),
        'fruit' => strings('categoryFruits'),
        'legume' => strings('categoryLegumes'),
        _ => strings('categoryOther'),
      };

  List<CropData> get _crops {
    var crops = CameruCropsDatabase.searchCrops(_query);
    if (_bucket != null) {
      crops = crops.where((crop) => _bucketFor(crop.category) == _bucket).toList();
    }
    return crops;
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LocaleProvider>().strings;
    final repo = context.watch<AppRepository>();
    final savedCropNames = repo.savedCrops.map((c) => c.cropName).toSet();
    final crops = _crops;

    return Scaffold(
      appBar: AppBar(title: Text(strings('cropDirectory'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              onChanged: (value) => setState(() => _query = value.trim()),
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                labelText: 'Search crops',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              children: [
                ChoiceChip(
                  label: Text(strings('allCrops')),
                  selected: _bucket == null,
                  onSelected: (_) => setState(() => _bucket = null),
                ),
                const SizedBox(width: 8),
                ..._categoryBuckets.map(
                  (bucket) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_bucketLabel(strings, bucket)),
                      selected: _bucket == bucket,
                      onSelected: (_) => setState(() => _bucket = bucket),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: crops.isEmpty
                ? Center(child: Text(strings('noCropsMatch')))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: crops.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, index) {
                      final crop = crops[index];
                      final saved = savedCropNames.contains(crop.name);
                      return CropCard(
                        crop: crop,
                        onTap: () => _showDetails(context, crop, repo, saved),
                        isSaved: saved,
                        onSave: () => _saveCrop(context, crop),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _saveCrop(BuildContext context, CropData crop) {
    final repo = context.read<AppRepository>();
    repo.saveCrop(SavedCrop(
      id: 'saved_${DateTime.now().microsecondsSinceEpoch}',
      cropName: crop.name,
      rationale: '${crop.name} suits ${crop.bestSoilType} soil with a pH around ${crop.optimalPh.toStringAsFixed(1)}.',
      savedAt: DateTime.now(),
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.read<LocaleProvider>().strings('savedToDashboard'))),
    );
  }

  void _showDetails(BuildContext context, CropData crop, AppRepository repo, bool saved) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Expanded(child: Text(crop.name, style: Theme.of(sheetContext).textTheme.headlineSmall)),
                IconButton(
                  icon: Icon(saved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded),
                  onPressed: saved
                      ? null
                      : () {
                          _saveCrop(context, crop);
                          Navigator.of(sheetContext).pop();
                        },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Detail(label: 'Planting guide', value: crop.plantingGuide),
            _Detail(label: 'Harvest period', value: crop.harvestMonth),
            _Detail(label: 'Days to maturity', value: '${crop.daysToMaturity} days'),
            _Detail(label: 'Pests and diseases', value: crop.pestsAndDiseases.join(', ')),
            _Detail(label: 'Watering', value: crop.wateringSchedule.join(', ')),
          ],
        ),
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(value),
          ],
        ),
      );
}
