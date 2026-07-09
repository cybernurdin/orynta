/// AgriForum: a farmer-to-farmer Q&A community, inspired by the SoilLens
/// prototype. Kept local/on-device like everything else in this MVP data
/// layer — a real backend would replace `ForumService` without touching
/// these shapes.
enum ForumCategory { pestControl, soilHealth, weather, market, general }

class ForumComment {
  final String id;
  final String author;
  final String body;
  final DateTime postedAt;

  const ForumComment({
    required this.id,
    required this.author,
    required this.body,
    required this.postedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'author': author,
        'body': body,
        'postedAt': postedAt.toIso8601String(),
      };

  factory ForumComment.fromJson(Map<String, dynamic> json) => ForumComment(
        id: json['id'] as String,
        author: json['author'] as String,
        body: json['body'] as String,
        postedAt: DateTime.parse(json['postedAt'] as String),
      );
}

class ForumPost {
  final String id;
  final String author;
  final ForumCategory category;
  final String body;
  final DateTime postedAt;
  final List<ForumComment> comments;

  const ForumPost({
    required this.id,
    required this.author,
    required this.category,
    required this.body,
    required this.postedAt,
    this.comments = const [],
  });

  ForumPost copyWith({List<ForumComment>? comments}) => ForumPost(
        id: id,
        author: author,
        category: category,
        body: body,
        postedAt: postedAt,
        comments: comments ?? this.comments,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'author': author,
        'category': category.name,
        'body': body,
        'postedAt': postedAt.toIso8601String(),
        'comments': comments.map((c) => c.toJson()).toList(),
      };

  factory ForumPost.fromJson(Map<String, dynamic> json) => ForumPost(
        id: json['id'] as String,
        author: json['author'] as String,
        category: ForumCategory.values.byName(json['category'] as String),
        body: json['body'] as String,
        postedAt: DateTime.parse(json['postedAt'] as String),
        comments: (json['comments'] as List)
            .map((e) => ForumComment.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
