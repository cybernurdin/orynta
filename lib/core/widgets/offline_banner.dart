import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../localization/app_strings.dart';

/// Per Orynta_Brand_Guide.md §6: empty/offline states must always explain
/// *why*, never show a blank screen or generic error.
class OfflineBanner extends StatelessWidget {
  final AppStrings strings;
  final int pendingCount;

  const OfflineBanner({
    super.key,
    required this.strings,
    this.pendingCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.amber.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, color: AppColors.amber, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              pendingCount > 0
                  ? '${strings('homeOffline')} ($pendingCount pending sync)'
                  : strings('homeOffline'),
              style: const TextStyle(color: AppColors.ink, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
