/// AgriForum: a farmer-to-farmer Q&A community, inspired by the SoilLens
/// prototype. Kept local/on-device like everything else in this MVP data
/// layer — a real backend would replace `ForumService` without touching
/// these shapes.
enum ForumCategory { soilManagement, plantHealth, pestControl, technology, successStories }

class ForumComment {
  final String id;
  final String author;
  final String userId;
  final String userPhotoUrl;
  final String body;
  final DateTime postedAt;

  const ForumComment({
    required this.id,
    required this.author,
    required this.body,
    required this.postedAt,
    this.userId = '',
    this.userPhotoUrl = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'author': author,
        'userId': userId,
        'userPhotoUrl': userPhotoUrl,
        'body': body,
        'postedAt': postedAt.toIso8601String(),
      };

  factory ForumComment.fromJson(Map<String, dynamic> json) => ForumComment(
        id: json['id'] as String,
        author: json['author'] as String,
        userId: json['userId'] as String? ?? '',
        userPhotoUrl: json['userPhotoUrl'] as String? ?? '',
        body: json['body'] as String,
        postedAt: DateTime.parse(json['postedAt'] as String),
      );
}

class ForumPost {
  final String id;
  final String author;
  final String userId;
  final String userPhotoUrl;
  final String userLevel;
  final String title;
  final ForumCategory category;
  final String body;
  final DateTime postedAt;
  final List<String> likedBy;
  final bool isPinned;
  final String? imageUrl;
  final List<ForumComment> comments;

  int get likes => likedBy.length;

  const ForumPost({
    required this.id,
    required this.author,
    required this.category,
    required this.body,
    required this.postedAt,
    this.userId = '',
    this.userPhotoUrl = '',
    this.userLevel = 'beginner',
    this.title = '',
    this.likedBy = const [],
    this.isPinned = false,
    this.imageUrl,
    this.comments = const [],
  });

  ForumPost copyWith({List<ForumComment>? comments, List<String>? likedBy, bool? isPinned}) => ForumPost(
        id: id,
        author: author,
        userId: userId,
        userPhotoUrl: userPhotoUrl,
        userLevel: userLevel,
        title: title,
        category: category,
        body: body,
        postedAt: postedAt,
        likedBy: likedBy ?? this.likedBy,
        isPinned: isPinned ?? this.isPinned,
        imageUrl: imageUrl,
        comments: comments ?? this.comments,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'author': author,
        'userId': userId,
        'userPhotoUrl': userPhotoUrl,
        'userLevel': userLevel,
        'title': title,
        'category': category.name,
        'body': body,
        'postedAt': postedAt.toIso8601String(),
        'likedBy': likedBy,
        'isPinned': isPinned,
        'imageUrl': imageUrl,
        'comments': comments.map((c) => c.toJson()).toList(),
      };

  factory ForumPost.fromJson(Map<String, dynamic> json) => ForumPost(
        id: json['id'] as String,
        author: json['author'] as String,
        userId: json['userId'] as String? ?? '',
        userPhotoUrl: json['userPhotoUrl'] as String? ?? '',
        userLevel: json['userLevel'] as String? ?? 'beginner',
        title: json['title'] as String? ?? (json['body'] as String).split('\n').first,
        category: _categoryFromJson(json['category'] as String),
        body: json['body'] as String,
        postedAt: DateTime.parse(json['postedAt'] as String),
        likedBy: (json['likedBy'] as List?)?.map((e) => e as String).toList() ?? const [],
        isPinned: json['isPinned'] as bool? ?? false,
        imageUrl: json['imageUrl'] as String?,
        comments: (json['comments'] as List)
            .map((e) => ForumComment.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Maps stored category names to the current enum, including the old
  /// pre-rename values (`soilHealth`/`weather`/`market`/`general`) so
  /// posts persisted before the category set was aligned to the requested
  /// Soil Management/Plant Health/Pest Control/Technology/Success Stories
  /// taxonomy still load instead of throwing.
  static ForumCategory _categoryFromJson(String name) => switch (name) {
        'soilHealth' => ForumCategory.soilManagement,
        'weather' || 'market' || 'general' => ForumCategory.plantHealth,
        _ => ForumCategory.values.byName(name),
      };
}
