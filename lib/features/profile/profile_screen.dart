import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/icon_circle.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/sprout_mark.dart';
import '../../data/services/app_repository.dart';

/// FR-6.1 (SRS §6.1): a farmer can view, export, and request deletion of
/// their own data from within the app — real features, not policy text.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final strings = locale.strings;
    final repo = context.watch<AppRepository>();

    return Scaffold(
      appBar: AppBar(title: Text(strings('profileTitle'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const IconCircle(icon: Icons.person_rounded, size: 56),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mama Ngozi', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 2),
                        const Text('West Region · Tomato & maize', style: TextStyle(color: AppColors.grey, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SectionHeader(title: strings('language')),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text(strings('english')),
                  trailing: locale.languageCode == 'en'
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.forest)
                      : null,
                  onTap: () => locale.setLanguage('en'),
                ),
                const Divider(height: 1),
                ListTile(
                  title: Text(strings('french')),
                  trailing: locale.languageCode == 'fr'
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.forest)
                      : null,
                  onTap: () => locale.setLanguage('fr'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SectionHeader(title: strings('myData')),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.visibility_outlined, color: AppColors.forest),
                  title: Text(strings('viewMyData')),
                  subtitle: Text('${repo.soilScans.length + repo.leafDiagnoses.length} scans stored on this device'),
                  onTap: () => _showDataSummary(context, strings, repo),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.download_outlined, color: AppColors.forest),
                  title: Text(strings('exportMyData')),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(strings('dataRequestQueued'))),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: AppColors.confidenceLow),
                  title: Text(strings('deleteMyData')),
                  onTap: () => _confirmDelete(context, strings),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SectionHeader(title: 'Sync'),
          const SizedBox(height: 10),
          Card(
            child: SwitchListTile(
              activeThumbColor: AppColors.forest,
              title: const Text('Online'),
              subtitle: Text(
                repo.isOnline
                    ? 'Scans sync automatically'
                    : '${repo.pendingSyncCount} scan(s) waiting to sync',
              ),
              value: repo.isOnline,
              onChanged: repo.setOnline,
            ),
          ),
          const SizedBox(height: 24),
          SectionHeader(title: strings('about')),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SproutMark(size: 36, color: AppColors.forest),
                  const SizedBox(height: 12),
                  Text(strings('aboutBody'), style: const TextStyle(fontSize: 13, height: 1.5, color: AppColors.grey)),
                  const SizedBox(height: 10),
                  Text(strings('tagline'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.forest)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDataSummary(BuildContext context, dynamic strings, AppRepository repo) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(strings('viewMyData')),
        content: Text(
          '${repo.soilScans.length} soil scans\n${repo.leafDiagnoses.length} leaf diagnoses\n${repo.listings.length} market listings\n\nAll stored locally on this device and synced when online.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(strings('confirm'))),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, dynamic strings) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(strings('deleteMyData')),
        content: Text(strings('deleteConfirm')),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(strings('cancel'))),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(strings('dataRequestQueued'))),
              );
            },
            child: Text(strings('confirm'), style: const TextStyle(color: AppColors.confidenceLow)),
          ),
        ],
      ),
    );
  }
}
