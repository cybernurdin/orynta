import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../localization/app_strings.dart';

/// Confidence badge per Orynta_Brand_Guide.md §3/§6/§8: always visible,
/// always color-coded, always paired with a plain-language label — never
/// color alone.
class ConfidenceBadge extends StatelessWidget {
  final double confidence;
  final AppStrings strings;

  const ConfidenceBadge({
    super.key,
    required this.confidence,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.confidenceColor(confidence);
    final label = confidence >= 0.75
        ? strings('confidenceHigh')
        : confidence >= 0.5
            ? strings('confidenceMedium')
            : strings('confidenceLow');
    final percent = (confidence * 100).round();

    return Semantics(
      label: '$label, $percent percent',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              '$label · $percent%',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
