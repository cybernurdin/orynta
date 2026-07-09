import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/icon_circle.dart';
import '../../data/models/app_notification.dart';
import '../../data/services/app_repository.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  IconData _iconFor(NotificationType type) => switch (type) {
        NotificationType.scanComplete => Icons.camera_alt_rounded,
        NotificationType.forumReply => Icons.forum_rounded,
        NotificationType.marketUpdate => Icons.storefront_rounded,
        NotificationType.officerMessage => Icons.support_agent_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LocaleProvider>().strings;
    final repo = context.watch<AppRepository>();
    final notifications = repo.notifications;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings('notifications')),
        actions: [
          if (notifications.any((n) => !n.read))
            TextButton(
              onPressed: () => repo.markAllNotificationsRead(),
              child: Text(strings('markAllRead')),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Text(strings('noNotifications'), style: const TextStyle(color: AppColors.grey)),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: notifications.map(
                (n) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  color: n.read ? null : AppColors.moss.withValues(alpha: 0.12),
                  child: ListTile(
                    onTap: () => repo.markNotificationRead(n.id),
                    leading: IconCircle(
                      icon: _iconFor(n.type),
                      background: n.read ? AppColors.grey : AppColors.forest,
                    ),
                    title: Text(n.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    subtitle: Text(n.body, style: const TextStyle(fontSize: 13)),
                    trailing: !n.read
                        ? Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(color: AppColors.amber, shape: BoxShape.circle),
                          )
                        : null,
                  ),
                ),
              ).toList(),
            ),
    );
  }
}
