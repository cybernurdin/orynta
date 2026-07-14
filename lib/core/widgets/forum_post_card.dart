import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../data/models/forum_post.dart';
import 'icon_circle.dart';

class ForumPostCard extends StatelessWidget {
  final ForumPost post;
  final String categoryLabel;
  final VoidCallback onTap;
  final VoidCallback onLike;
  final VoidCallback onBookmark;
  final bool isLiked;
  final bool isBookmarked;

  const ForumPostCard({
    super.key,
    required this.post,
    required this.categoryLabel,
    required this.onTap,
    required this.onLike,
    required this.onBookmark,
    this.isLiked = false,
    this.isBookmarked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (post.userPhotoUrl.isEmpty)
                    const IconCircle(icon: Icons.person_rounded, size: 44)
                  else
                    ClipOval(
                      child: Image.network(
                        post.userPhotoUrl,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const IconCircle(icon: Icons.person_rounded, size: 44),
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                post.author,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _LevelBadge(level: post.userLevel),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(post.postedAt),
                          style: const TextStyle(fontSize: 12, color: AppColors.grey),
                        ),
                      ],
                    ),
                  ),
                  if (post.isPinned) const Icon(Icons.push_pin_rounded, color: AppColors.amber, size: 20),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.moss.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  categoryLabel,
                  style: const TextStyle(color: AppColors.forest, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                post.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                post.body,
                style: const TextStyle(fontSize: 14, color: AppColors.grey, height: 1.5),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              if (post.imageUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _PostImage(path: post.imageUrl!),
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  _EngagementButton(
                    icon: isLiked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                    label: post.likes.toString(),
                    onTap: onLike,
                    isActive: isLiked,
                  ),
                  const SizedBox(width: 20),
                  _EngagementButton(
                    icon: Icons.mode_comment_outlined,
                    label: post.comments.length.toString(),
                    onTap: onTap,
                  ),
                  const Spacer(),
                  _EngagementButton(
                    icon: isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
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
}

class _LevelBadge extends StatelessWidget {
  final String level;
  const _LevelBadge({required this.level});

  Color get _color => switch (level) {
        'expert_farmer' => AppColors.forest,
        'intermediate' => AppColors.amber,
        _ => AppColors.grey,
      };

  String get _label => switch (level) {
        'expert_farmer' => 'Expert farmer',
        'intermediate' => 'Intermediate',
        _ => 'Beginner farmer',
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: _color, borderRadius: BorderRadius.circular(12)),
      child: Text(
        _label,
        style: const TextStyle(color: AppColors.white, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// Renders either a network URL (seeded content) or a locally-picked photo
/// (`image_picker` path from `NewPostSheet`), matching the same
/// kIsWeb-guarded pattern used in `capture_screen.dart`.
class _PostImage extends StatelessWidget {
  final String path;
  const _PostImage({required this.path});

  @override
  Widget build(BuildContext context) {
    const height = 150.0;
    if (path.startsWith('http')) {
      return Image.network(
        path,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholder(),
      );
    }
    if (kIsWeb) return _placeholder();
    return Image.file(
      File(path),
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _placeholder(),
    );
  }

  Widget _placeholder() => Container(
        height: 150,
        color: AppColors.moss.withValues(alpha: 0.15),
        child: const Center(child: Icon(Icons.image_outlined, size: 32, color: AppColors.grey)),
      );
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
            color: isActive ? AppColors.confidenceLow : AppColors.grey,
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.grey, fontWeight: FontWeight.w500),
            ),
          ],
        ],
      ),
    );
  }
}
