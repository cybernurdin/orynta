import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/icon_circle.dart';
import '../../data/services/app_repository.dart';

class TopContributorsScreen extends StatelessWidget {
  const TopContributorsScreen({super.key});

  String _levelLabel(String level) => switch (level) {
        'expert_farmer' => 'Expert farmer',
        'intermediate' => 'Intermediate',
        _ => 'Beginner farmer',
      };

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LocaleProvider>().strings;
    final contributors = context.watch<AppRepository>().topContributors;

    return Scaffold(
      appBar: AppBar(title: Text(strings('topContributors'))),
      body: contributors.isEmpty
          ? Center(child: Text(strings('noForumPosts'), style: const TextStyle(color: AppColors.grey)))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: contributors.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, index) {
                final c = contributors[index];
                return Card(
                  child: ListTile(
                    leading: SizedBox(
                      width: 44,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.grey)),
                          const SizedBox(width: 8),
                          const IconCircle(icon: Icons.person_rounded, size: 36),
                        ],
                      ),
                    ),
                    title: Text(c.userName, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(
                      '${_levelLabel(c.userLevel)} · ${c.postsCount} posts · ${c.commentsCount} comments',
                      style: const TextStyle(fontSize: 12, color: AppColors.grey),
                    ),
                    trailing: Text(
                      '${c.points} ${strings('points')}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.forest),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
