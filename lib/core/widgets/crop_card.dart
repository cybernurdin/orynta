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
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder with category badge
            Stack(
              children: [
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: crop.imageUrl != null
                      ? Image.network(
                          crop.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholder(crop.category);
                          },
                        )
                      : _buildPlaceholder(crop.category),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(crop.category),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      crop.category.replaceAll('_', ' '),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    crop.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(label: 'Soil', value: crop.bestSoilType),
                  _InfoRow(label: 'pH', value: '${crop.optimalPh}'),
                  _InfoRow(
                    label: 'Moisture',
                    value: '${crop.optimalMoisture.toStringAsFixed(0)}%',
                  ),
                  _InfoRow(
                    label: 'Plant',
                    value: crop.plantingMonth,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onTap,
                      child: const Text('View Planting Guide'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(String category) {
    final icon = _getCategoryIcon(category);
    return Container(
      color: _getCategoryColor(category).withOpacity(0.1),
      child: Center(
        child: Icon(
          icon,
          size: 48,
          color: _getCategoryColor(category),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'vegetable':
        return const Color(0xFF4CAF50);
      case 'grain':
        return const Color(0xFFFF9800);
      case 'fruit':
        return const Color(0xFFE91E63);
      case 'legume':
        return const Color(0xFF2196F3);
      case 'root_crop':
        return const Color(0xFF8D6E63);
      case 'cash_crop':
        return const Color(0xFF795548);
      default:
        return const Color(0xFF607D8B);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'vegetable':
        return Icons.eco;
      case 'grain':
        return Icons.grain;
      case 'fruit':
        return Icons.apple;
      case 'legume':
        return Icons.blur_on;
      case 'root_crop':
        return Icons.nature;
      case 'cash_crop':
        return Icons.local_florist;
      default:
        return Icons.eco;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
