import 'package:flutter/material.dart';
import '../../data/models/crop_data.dart';

class CropCard extends StatelessWidget {
  final CropData crop;
  final VoidCallback onTap;
  final bool showFilter;

  const CropCard({
    Key? key,
    required this.crop,
    required this.onTap,
    this.showFilter = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 176,
                  width: double.infinity,
                  child: Image.network(
                    crop.imageUrl ?? _defaultImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const ColoredBox(color: Color(0xFFE7EAE2)),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: _CategoryBadge(category: crop.category),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          crop.name,
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _Fact(label: 'Best soil', value: crop.bestSoilType)),
                      Expanded(child: _Fact(label: 'pH level', value: crop.optimalPh.toStringAsFixed(1))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _Fact(label: 'Temperature', value: '${crop.minTemp.round()}-${crop.maxTemp.round()} C')),
                      Expanded(child: _Fact(label: 'Moisture', value: '${crop.optimalMoisture.round()}%')),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text('Plant ${crop.plantingMonth}', style: const TextStyle(fontSize: 13, color: Color(0xFF546154))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _defaultImageUrl = 'https://images.unsplash.com/photo-1464226184884-fa280b87c399?auto=format&fit=crop&w=1200&q=80';
}

class _Fact extends StatelessWidget {
  final String label;
  final String value;

  const _Fact({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7568))),
        const SizedBox(height: 2),
        Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.category});
  final String category;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.58), borderRadius: BorderRadius.circular(4)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Text(category.replaceAll('_', ' '), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
        ),
      );
}
