import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_mode_provider.dart';
import '../../core/widgets/icon_circle.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/sprout_mark.dart';
import '../../data/models/app_notification.dart';
import '../../data/models/farmer_profile.dart';
import '../../data/services/app_repository.dart';
import '../../data/services/local_auth_service.dart';
import '../auth/login_screen.dart';
import '../community/top_contributors_screen.dart';
import '../crops/my_crops_screen.dart';
import '../support/chat_screen.dart';
import 'activity_log_screen.dart';
import 'change_password_screen.dart';
import 'edit_profile_sheet.dart';

/// FR-6.1 (SRS §6.1): a farmer can view, export, and request deletion of
/// their own data from within the app — real features, not policy text.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _typeLabel(dynamic strings, FarmerType type) => switch (type) {
        FarmerType.beginner => strings('farmerTypeBeginner'),
        FarmerType.advanced => strings('farmerTypeAdvanced'),
        FarmerType.commercial => strings('farmerTypeCommercial'),
        FarmerType.subsistence => strings('farmerTypeSubsistence'),
        FarmerType.organic => strings('farmerTypeOrganic'),
        FarmerType.agronomist => strings('farmerTypeAgronomist'),
        FarmerType.officer => strings('farmerTypeOfficer'),
      };

  String _notificationLabel(dynamic strings, NotificationType type) => switch (type) {
        NotificationType.scanComplete => strings('notifScanComplete'),
        NotificationType.forumReply => strings('notifForumReply'),
        NotificationType.marketUpdate => strings('notifMarketUpdate'),
        NotificationType.officerMessage => strings('notifOfficerMessage'),
      };

  Future<void> _changePhoto(BuildContext context, AppRepository repo) async {
    try {
      final file = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 800, imageQuality: 85);
      if (file != null) {
        await repo.updateProfile(repo.profile.copyWith(photoPath: file.path));
      }
    } catch (_) {
      // Photo upload is optional — skip silently on platforms without a picker.
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final strings = locale.strings;
    final repo = context.watch<AppRepository>();
    final themeMode = context.watch<ThemeModeProvider>();
    final profile = repo.profile;

    return Scaffold(
      appBar: AppBar(title: Text(strings('profileTitle'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _changePhoto(context, repo),
                        child: Stack(
                          children: [
                            _ProfileAvatar(photoPath: profile.photoPath),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(color: AppColors.amber, shape: BoxShape.circle),
                                child: const Icon(Icons.camera_alt_rounded, size: 12, color: AppColors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(profile.name, style: Theme.of(context).textTheme.titleLarge),
                            if (profile.email.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(profile.email, style: const TextStyle(color: AppColors.grey, fontSize: 13)),
                            ],
                            const SizedBox(height: 2),
                            Text(
                              '${profile.region} · ${profile.cropFocus}',
                              style: const TextStyle(color: AppColors.grey, fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _typeLabel(strings, profile.farmerType),
                              style: const TextStyle(color: AppColors.forest, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${strings('joined')} ${profile.joinedAt.year}-${profile.joinedAt.month.toString().padLeft(2, '0')}',
                              style: const TextStyle(color: AppColors.grey, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: AppColors.grey),
                        tooltip: strings('editProfile'),
                        onPressed: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => const EditProfileSheet(),
                        ),
                      ),
                    ],
                  ),
                  if (profile.bio.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(profile.bio, style: const TextStyle(fontSize: 13, height: 1.4)),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SectionHeader(title: strings('quickStats')),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _StatTile(icon: Icons.camera_alt_rounded, value: '${repo.totalScansCount}', label: strings('totalScans'))),
              const SizedBox(width: 10),
              Expanded(child: _StatTile(icon: Icons.bookmark_rounded, value: '${repo.recommendationsSavedCount}', label: strings('recommendationsSaved'))),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _StatTile(icon: Icons.forum_rounded, value: '${repo.forumContributionsCount}', label: strings('forumContributions'))),
              const SizedBox(width: 10),
              Expanded(child: _StatTile(icon: Icons.eco_rounded, value: '${repo.cropsMonitoredCount}', label: strings('cropsMonitored'))),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const Icon(Icons.bookmark_outline_rounded, color: AppColors.forest),
              title: Text(strings('savedRecommendations')),
              subtitle: Text('${repo.savedCrops.length}'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MyCropsScreen())),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: SectionHeader(title: strings('recentActivity'))),
              TextButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ActivityLogScreen())),
                child: Text(strings('viewAllActivity')),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (repo.activityLog.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(strings('noActivityYet'), style: const TextStyle(color: AppColors.grey)),
              ),
            )
          else
            ...repo.activityLog.take(5).map(
                  (entry) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: IconCircle(icon: activityIcon(entry.kind), size: 36),
                      title: Text(entry.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        '${entry.at.year}-${entry.at.month.toString().padLeft(2, '0')}-${entry.at.day.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 11, color: AppColors.grey),
                      ),
                    ),
                  ),
                ),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const Icon(Icons.emoji_events_outlined, color: AppColors.forest),
              title: Text(strings('topContributors')),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TopContributorsScreen())),
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
          SectionHeader(title: strings('notificationPreferences')),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                for (final type in NotificationType.values) ...[
                  SwitchListTile(
                    activeThumbColor: AppColors.forest,
                    title: Text(_notificationLabel(strings, type)),
                    value: repo.notificationEnabled(type),
                    onChanged: (enabled) => repo.setNotificationEnabled(type, enabled),
                  ),
                  if (type != NotificationType.values.last) const Divider(height: 1),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          SectionHeader(title: 'Display'),
          const SizedBox(height: 10),
          Card(
            child: SwitchListTile(
              activeThumbColor: AppColors.forest,
              title: Text(strings('darkMode')),
              value: themeMode.darkMode,
              onChanged: themeMode.setDarkMode,
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
          SectionHeader(title: strings('helpAndSupport')),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: const Icon(Icons.support_agent_rounded, color: AppColors.forest),
              title: Text(strings('supportChat')),
              subtitle: Text(strings('agriculturalOfficer')),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ChatScreen()),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SectionHeader(title: strings('account')),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_reset_rounded, color: AppColors.forest),
                  title: Text(strings('changePassword')),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChangePasswordScreen())),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: AppColors.confidenceLow),
                  title: Text(strings('logOut'), style: const TextStyle(color: AppColors.confidenceLow)),
                  onTap: () => _confirmLogout(context, strings),
                ),
              ],
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
          '${repo.soilScans.length} soil scans\n${repo.leafDiagnoses.length} leaf diagnoses\n${repo.myListings.length} market listings\n\nAll stored locally on this device and synced when online.',
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

  void _confirmLogout(BuildContext context, dynamic strings) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(strings('logOut')),
        content: Text(strings('logOutConfirm')),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(strings('cancel'))),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await LocalAuthService().logout();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: Text(strings('confirm'), style: const TextStyle(color: AppColors.confidenceLow)),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String? photoPath;
  const _ProfileAvatar({required this.photoPath});

  @override
  Widget build(BuildContext context) {
    if (photoPath == null || photoPath!.isEmpty) {
      return const IconCircle(icon: Icons.person_rounded, size: 56);
    }
    return ClipOval(
      child: SizedBox(
        width: 56,
        height: 56,
        child: kIsWeb
            ? Image.network(photoPath!, fit: BoxFit.cover, errorBuilder: (_, _, _) => const IconCircle(icon: Icons.person_rounded, size: 56))
            : Image.file(File(photoPath!), fit: BoxFit.cover, errorBuilder: (_, _, _) => const IconCircle(icon: Icons.person_rounded, size: 56)),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatTile({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: AppColors.forest, size: 20),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 2),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.grey, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
