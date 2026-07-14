/// A derived, read-only feed item for Profile's Activity Log / Recent
/// Activity section. Never persisted directly — always rebuilt from the
/// real records it summarizes (scans, posts, comments, chats, saves,
/// listings) so it can never drift out of sync with them.
enum ActivityKind { soilScan, leafScan, forumPost, forumComment, chatMessage, cropSaved, productListed }

class ActivityLogEntry {
  final String id;
  final ActivityKind kind;
  final String title;
  final DateTime at;

  const ActivityLogEntry({
    required this.id,
    required this.kind,
    required this.title,
    required this.at,
  });
}
