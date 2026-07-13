import 'package:flutter/material.dart';

import '../../core/widgets/crop_card.dart';
import '../../data/models/crop_data.dart';

class CropsDirectoryScreen extends StatefulWidget {
  const CropsDirectoryScreen({super.key});

  @override
  State<CropsDirectoryScreen> createState() => _CropsDirectoryScreenState();
}

class _CropsDirectoryScreenState extends State<CropsDirectoryScreen> {
  String _query = '';
  String? _category;

  List<CropData> get _crops {
    var crops = CameruCropsDatabase.searchCrops(_query);
    if (_category != null) {
      crops = crops.where((crop) => crop.category == _category).toList();
    }
    return crops;
  }

  @override
  Widget build(BuildContext context) {
    final categories = CameruCropsDatabase.getAllCategories()..sort();
    final crops = _crops;

    return Scaffold(
      appBar: AppBar(title: const Text('Crop directory')),
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
                  label: const Text('All'),
                  selected: _category == null,
                  onSelected: (_) => setState(() => _category = null),
                ),
                const SizedBox(width: 8),
                ...categories.map(
                  (category) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category.replaceAll('_', ' ')),
                      selected: _category == category,
                      onSelected: (_) => setState(() => _category = category),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: crops.isEmpty
                ? const Center(child: Text('No crops match your search.'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: crops.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, index) {
                      final crop = crops[index];
                      return CropCard(
                        crop: crop,
                        onTap: () => _showDetails(crop),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showDetails(CropData crop) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.all(20),
          children: [
            Text(crop.name, style: Theme.of(context).textTheme.headlineSmall),
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
