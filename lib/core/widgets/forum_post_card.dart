import 'package:flutter/material.dart';
import '../../data/models/forum_model.dart';

class ForumPostCard extends StatelessWidget {
  final ForumPost post;
  final VoidCallback onTap;
  final VoidCallback onLike;
  final VoidCallback onBookmark;
  final bool isLiked;
  final bool isBookmarked;

  const ForumPostCard({
    Key? key,
    required this.post,
    required this.onTap,
    required this.onLike,
    required this.onBookmark,
    this.isLiked = false,
    this.isBookmarked = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info header
              Row(
                children: [
                  // User avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[300],
                      image: DecorationImage(
                        image: NetworkImage(post.userPhotoUrl),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {},
                      ),
                    ),
                    child: post.userPhotoUrl.isEmpty
                        ? Center(
                            child: Icon(
                              Icons.person,
                              color: Colors.grey[600],
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              post.userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getUserLevelColor(post.userLevel),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                post.userLevel.replaceAll('_', ' ').toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(post.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (post.isPinned)
                    const Icon(
                      Icons.push_pin,
                      color: Colors.orange,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Category badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getCategoryColor(post.category).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  post.category.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(
                    color: _getCategoryColor(post.category),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Post title and content
              Text(
                post.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                post.content,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Image if exists
              if (post.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    post.imageUrl!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.image, size: 40),
                        ),
                      );
                    },
                  ),
                ),
              if (post.imageUrl != null) const SizedBox(height: 12),

              // Engagement metrics
              Row(
                children: [
                  _EngagementButton(
                    icon: isLiked ? Icons.favorite : Icons.favorite_outline,
                    label: post.likes.toString(),
                    onTap: onLike,
                    isActive: isLiked,
                  ),
                  const SizedBox(width: 16),
                  _EngagementButton(
                    icon: Icons.comment_outlined,
                    label: post.comments.toString(),
                    onTap: onTap,
                  ),
                  const Spacer(),
                  _EngagementButton(
                    icon: isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                    label: '',
                    onTap: onBookmark,
                    isActive: isBookmarked,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return dateTime.toString().split(' ')[0];
    }
  }

  Color _getUserLevelColor(String level) {
    switch (level) {
      case 'expert_farmer':
        return const Color(0xFF4CAF50);
      case 'intermediate':
        return const Color(0xFFFFC107);
      case 'beginner':
        return const Color(0xFF2196F3);
      default:
        return Colors.grey;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'soil_management':
        return const Color(0xFF8D6E63);
      case 'plant_health':
        return const Color(0xFF4CAF50);
      case 'pest_control':
        return const Color(0xFFE91E63);
      case 'technology':
        return const Color(0xFF2196F3);
      case 'success_stories':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF607D8B);
    }
  }
}

class _EngagementButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _EngagementButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isActive ? Colors.red : Colors.grey[600],
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
