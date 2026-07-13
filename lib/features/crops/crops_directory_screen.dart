import 'package:flutter/material.dart';
import '../../core/widgets/crop_card.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/crop_data.dart';

class CropsDirectoryScreen extends StatefulWidget {
  const CropsDirectoryScreen({super.key});

  @override
  State<CropsDirectoryScreen> createState() => _CropsDirectoryScreenState();
}

class _CropsDirectoryScreenState extends State<CropsDirectoryScreen> {
  late TextEditingController _searchController;
  String? _selectedCategory;
  List<CropData> _filteredCrops = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadCrops();
    _searchController.addListener(_filterCrops);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadCrops() {
    setState(() {
      _filteredCrops = CameruCropsDatabase.cropsData;
    });
  }

  void _filterCrops() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCrops = CameruCropsDatabase.cropsData.where((crop) {
        final matchesSearch = crop.name.toLowerCase().contains(query) ||
            crop.category.toLowerCase().contains(query);
        final matchesCategory = _selectedCategory == null || crop.category == _selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = CameruCropsDatabase.getAllCategories();

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('Crops Directory'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search crops...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _filterCrops();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),

            // Category filter chips
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: const Text('All'),
                        selected: _selectedCategory == null,
                        onSelected: (_) {
                          setState(() => _selectedCategory = null);
                          _filterCrops();
                        },
                      ),
                    );
                  }
                  final category = categories[index - 1];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category.replaceAll('_', ' ')),
                      selected: _selectedCategory == category,
                      onSelected: (_) {
                        setState(() => _selectedCategory = category);
                        _filterCrops();
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Crops grid
            if (_filteredCrops.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No crops found',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _filteredCrops.length,
                  itemBuilder: (context, index) {
                    final crop = _filteredCrops[index];
                    return CropCard(
                      crop: crop,
                      onTap: () {
                        _showCropDetails(crop);
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showCropDetails(CropData crop) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  crop.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                _DetailSection(
                  title: 'Soil Requirements',
                  content: crop.bestSoilType,
                ),
                _DetailSection(
                  title: 'Optimal pH',
                  content: '${crop.optimalPh}',
                ),
                _DetailSection(
                  title: 'Temperature Range',
                  content: '${crop.minTemp}°C - ${crop.maxTemp}°C',
                ),
                _DetailSection(
                  title: 'Optimal Moisture',
                  content: '${crop.optimalMoisture.toStringAsFixed(0)}%',
                ),
                _DetailSection(
                  title: 'Planting Period',
                  content: crop.plantingMonth,
                ),
                _DetailSection(
                  title: 'Harvest Period',
                  content: crop.harvestMonth,
                ),
                _DetailSection(
                  title: 'Days to Maturity',
                  content: '${crop.daysToMaturity} days',
                ),
                const SizedBox(height: 16),
                Text(
                  'Planting Guide',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  crop.plantingGuide,
                  style: const TextStyle(height: 1.6),
                ),
                const SizedBox(height: 16),
                Text(
                  'Companion Plants',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: crop.companionPlants
                      .map((plant) => Chip(label: Text(plant)))
                      .toList(),
                ),
                const SizedBox(height: 16),
                Text(
                  'Pests & Diseases',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                ...crop.pestsAndDiseases
                    .map((pest) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber, size: 16),
                              const SizedBox(width: 8),
                              Text(pest),
                            ],
                          ),
                        ))
                    .toList(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final String content;

  const _DetailSection({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            content,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
