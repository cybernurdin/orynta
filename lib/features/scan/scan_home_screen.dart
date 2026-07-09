import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/icon_circle.dart';
import 'capture_screen.dart';
import 'scan_type.dart';

/// FR-7.4: max 3 taps to any core scan feature. This screen is tap 1
/// (from the bottom nav), capture is tap 2, analyze is tap 3.
class ScanHomeScreen extends StatelessWidget {
  const ScanHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LocaleProvider>().strings;

    return Scaffold(
      appBar: AppBar(title: Text(strings('scanTitle'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ScanOptionCard(
            icon: Icons.grass_rounded,
            iconBackground: AppColors.forest,
            title: strings('scanSoilTitle'),
            description: strings('scanSoilDesc'),
            buttonLabel: strings('quickScanSoil'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const CaptureScreen(type: ScanType.soil),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _ScanOptionCard(
            icon: Icons.eco_rounded,
            iconBackground: AppColors.amber,
            title: strings('scanLeafTitle'),
            description: strings('scanLeafDesc'),
            buttonLabel: strings('quickScanLeaf'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const CaptureScreen(type: ScanType.leaf),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanOptionCard extends StatelessWidget {
  final IconData icon;
  final Color iconBackground;
  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback onTap;

  const _ScanOptionCard({
    required this.icon,
    required this.iconBackground,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconCircle(icon: icon, background: iconBackground),
              const SizedBox(height: 14),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.grey,
                    ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onTap,
                  child: Text(buttonLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
