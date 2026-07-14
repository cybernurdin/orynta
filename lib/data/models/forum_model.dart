class Announcement {
  final String announcementId;
  final String title;
  final String content;
  final DateTime publishedAt;
  final DateTime? eventDate;
  final String? imageUrl;
  final String category; // 'webinar', 'event', 'news', 'update'

  Announcement({
    required this.announcementId,
    required this.title,
    required this.content,
    required this.publishedAt,
    this.eventDate,
    this.imageUrl,
    this.category = 'news',
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      announcementId: json['announcementId'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      eventDate: json['eventDate'] != null ? DateTime.parse(json['eventDate'] as String) : null,
      imageUrl: json['imageUrl'] as String?,
      category: json['category'] as String? ?? 'news',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'announcementId': announcementId,
      'title': title,
      'content': content,
      'publishedAt': publishedAt.toIso8601String(),
      'eventDate': eventDate?.toIso8601String(),
      'imageUrl': imageUrl,
      'category': category,
    };
  }
}

/// Computed (not stored) leaderboard entry — see AppRepository.topContributors.
class TopContributor {
  final String userId;
  final String userName;
  final String userPhotoUrl;
  final int points;
  final int postsCount;
  final int commentsCount;
  final String userLevel;

  TopContributor({
    required this.userId,
    required this.userName,
    required this.userPhotoUrl,
    required this.points,
    required this.postsCount,
    required this.commentsCount,
    required this.userLevel,
  });
}
