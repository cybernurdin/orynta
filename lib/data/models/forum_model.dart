class ForumPost {
  final String postId;
  final String userId;
  final String userName;
  final String userPhotoUrl;
  final String userLevel; // 'expert_farmer', 'beginner', 'intermediate'
  final String title;
  final String content;
  final String category; // 'soil_management', 'plant_health', 'pest_control', 'technology', 'success_stories'
  final DateTime createdAt;
  final int likes;
  final int comments;
  final List<String> likedBy; // user IDs
  final bool isPinned;
  final String? imageUrl;

  ForumPost({
    required this.postId,
    required this.userId,
    required this.userName,
    required this.userPhotoUrl,
    required this.userLevel,
    required this.title,
    required this.content,
    required this.category,
    required this.createdAt,
    required this.likes,
    required this.comments,
    required this.likedBy,
    this.isPinned = false,
    this.imageUrl,
  });

  factory ForumPost.fromJson(Map<String, dynamic> json) {
    return ForumPost(
      postId: json['postId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userPhotoUrl: json['userPhotoUrl'] as String,
      userLevel: json['userLevel'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      category: json['category'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      likes: json['likes'] as int,
      comments: json['comments'] as int,
      likedBy: List<String>.from(json['likedBy'] as List? ?? []),
      isPinned: json['isPinned'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'userLevel': userLevel,
      'title': title,
      'content': content,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'comments': comments,
      'likedBy': likedBy,
      'isPinned': isPinned,
      'imageUrl': imageUrl,
    };
  }
}

class ForumComment {
  final String commentId;
  final String postId;
  final String userId;
  final String userName;
  final String userPhotoUrl;
  final String userLevel;
  final String content;
  final DateTime createdAt;
  final int likes;
  final List<String> likedBy;
  final String? imageUrl;

  ForumComment({
    required this.commentId,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.userPhotoUrl,
    required this.userLevel,
    required this.content,
    required this.createdAt,
    required this.likes,
    required this.likedBy,
    this.imageUrl,
  });

  factory ForumComment.fromJson(Map<String, dynamic> json) {
    return ForumComment(
      commentId: json['commentId'] as String,
      postId: json['postId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userPhotoUrl: json['userPhotoUrl'] as String,
      userLevel: json['userLevel'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      likes: json['likes'] as int,
      likedBy: List<String>.from(json['likedBy'] as List? ?? []),
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'commentId': commentId,
      'postId': postId,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'userLevel': userLevel,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'likedBy': likedBy,
      'imageUrl': imageUrl,
    };
  }
}

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

  factory TopContributor.fromJson(Map<String, dynamic> json) {
    return TopContributor(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userPhotoUrl: json['userPhotoUrl'] as String,
      points: json['points'] as int,
      postsCount: json['postsCount'] as int,
      commentsCount: json['commentsCount'] as int,
      userLevel: json['userLevel'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'points': points,
      'postsCount': postsCount,
      'commentsCount': commentsCount,
      'userLevel': userLevel,
    };
  }
}
