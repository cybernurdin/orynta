import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/icon_circle.dart';

const List<String> _quickTips = [
  'Rotate crop families each season to break pest and disease cycles.',
  'Mulch bare soil to retain moisture and suppress weeds between rains.',
  'Test soil pH before applying lime or fertilizer — over-correcting wastes input costs.',
  'Plant nitrogen-fixing legumes like beans or groundnut between grain seasons.',
  'Water in the early morning or late evening to reduce evaporation loss.',
  'Space plants for airflow — overcrowding raises fungal disease risk.',
  'Compost crop residue instead of burning it to rebuild soil organic matter.',
  'Scout leaves weekly during the rainy season — early pest detection saves the harvest.',
  'Avoid working wet clay soil — it compacts and damages root structure.',
  "Keep a simple planting log — it makes next season's crop rotation easier to plan.",
];

/// A rotating agronomy tip on the dashboard. Deterministic by day-of-year
/// rather than random, so the tip doesn't visibly change on every rebuild;
/// tapping cycles to the next one for a farmer who wants more.
class QuickTipsSection extends StatefulWidget {
  const QuickTipsSection({super.key});

  @override
  State<QuickTipsSection> createState() => _QuickTipsSectionState();
}

class _QuickTipsSectionState extends State<QuickTipsSection> {
  late int _index = DateTime.now().day % _quickTips.length;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => setState(() => _index = (_index + 1) % _quickTips.length),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const IconCircle(icon: Icons.lightbulb_outline_rounded, background: AppColors.amber, size: 40),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  _quickTips[_index],
                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, color: AppColors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
