import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/icon_circle.dart';
import '../../data/models/farmer_profile.dart';
import '../../data/models/forum_post.dart';
import '../../data/services/app_repository.dart';

class ForumPostDetailScreen extends StatefulWidget {
  final String postId;
  const ForumPostDetailScreen({super.key, required this.postId});

  @override
  State<ForumPostDetailScreen> createState() => _ForumPostDetailScreenState();
}

class _ForumPostDetailScreenState extends State<ForumPostDetailScreen> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LocaleProvider>().strings;
    final repo = context.watch<AppRepository>();
    final post = repo.forumPosts.firstWhere(
      (p) => p.id == widget.postId,
      orElse: () => ForumPost(
        id: widget.postId,
        author: '',
        category: ForumCategory.plantHealth,
        body: '',
        postedAt: DateTime.now(),
      ),
    );
    final isLiked = post.likedBy.contains(repo.profile.email);
    final canPin = repo.profile.farmerType == FarmerType.officer;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings('communityPost')),
        actions: [
          if (canPin)
            IconButton(
              icon: Icon(post.isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined),
              tooltip: post.isPinned ? strings('unpinPost') : strings('pinPost'),
              onPressed: () => repo.togglePin(post.id),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const IconCircle(icon: Icons.person_rounded, size: 36),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(post.author, style: const TextStyle(fontWeight: FontWeight.w700)),
                                  Text(
                                    '${post.postedAt.year}-${post.postedAt.month.toString().padLeft(2, '0')}-${post.postedAt.day.toString().padLeft(2, '0')}',
                                    style: const TextStyle(color: AppColors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            if (post.isPinned) const Icon(Icons.push_pin_rounded, color: AppColors.amber, size: 18),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(post.title, style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 10),
                        Text(post.body, style: const TextStyle(fontSize: 14, height: 1.4)),
                        const SizedBox(height: 14),
                        InkWell(
                          onTap: () => repo.toggleLike(post.id),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isLiked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                                size: 20,
                                color: isLiked ? AppColors.confidenceLow : AppColors.grey,
                              ),
                              const SizedBox(width: 6),
                              Text('${post.likes}', style: const TextStyle(color: AppColors.grey, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${post.comments.length} ${strings('comments')}',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.grey),
                ),
                const SizedBox(height: 10),
                ...post.comments.map(
                  (c) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.author, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(c.body, style: const TextStyle(fontSize: 13, height: 1.3)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(hintText: strings('shareYourThoughts')),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    icon: const Icon(Icons.send_rounded),
                    onPressed: () {
                      final body = _commentController.text.trim();
                      if (body.isEmpty) return;
                      context.read<AppRepository>().addForumComment(
                            post.id,
                            ForumComment(
                              id: 'comment_${DateTime.now().microsecondsSinceEpoch}',
                              author: repo.profile.name,
                              userId: repo.profile.email,
                              body: body,
                              postedAt: DateTime.now(),
                            ),
                          );
                      _commentController.clear();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
