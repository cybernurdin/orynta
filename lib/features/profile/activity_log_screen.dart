import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/icon_circle.dart';
import '../../data/models/activity_log_entry.dart';
import '../../data/services/app_repository.dart';

IconData activityIcon(ActivityKind kind) => switch (kind) {
      ActivityKind.soilScan => Icons.grass_rounded,
      ActivityKind.leafScan => Icons.eco_rounded,
      ActivityKind.forumPost => Icons.forum_rounded,
      ActivityKind.forumComment => Icons.mode_comment_outlined,
      ActivityKind.chatMessage => Icons.support_agent_rounded,
      ActivityKind.cropSaved => Icons.bookmark_rounded,
      ActivityKind.productListed => Icons.storefront_rounded,
    };

class ActivityLogScreen extends StatelessWidget {
  const ActivityLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LocaleProvider>().strings;
    final activity = context.watch<AppRepository>().activityLog;

    return Scaffold(
      appBar: AppBar(title: Text(strings('activityLog'))),
      body: activity.isEmpty
          ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(strings('noActivityYet'), style: const TextStyle(color: AppColors.grey), textAlign: TextAlign.center)))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: activity.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final entry = activity[i];
                return Card(
                  child: ListTile(
                    leading: IconCircle(icon: activityIcon(entry.kind), size: 40),
                    title: Text(entry.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      '${entry.at.year}-${entry.at.month.toString().padLeft(2, '0')}-${entry.at.day.toString().padLeft(2, '0')} '
                      '${entry.at.hour.toString().padLeft(2, '0')}:${entry.at.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 11, color: AppColors.grey),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
