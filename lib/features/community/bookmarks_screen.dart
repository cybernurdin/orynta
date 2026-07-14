import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/forum_post_card.dart';
import '../../data/services/app_repository.dart';
import 'forum_post_detail_screen.dart';
import 'forum_screen.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LocaleProvider>().strings;
    final repo = context.watch<AppRepository>();
    final myEmail = repo.profile.email;
    final bookmarked = repo.forumPosts.where((p) => repo.bookmarkedPostIds.contains(p.id)).toList();

    return Scaffold(
      appBar: AppBar(title: Text(strings('bookmarks'))),
      body: bookmarked.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(strings('noBookmarksYet'), style: const TextStyle(color: AppColors.grey), textAlign: TextAlign.center),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: bookmarked
                  .map(
                    (post) => ForumPostCard(
                      post: post,
                      categoryLabel: categoryLabel(strings, post.category),
                      isLiked: post.likedBy.contains(myEmail),
                      isBookmarked: true,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => ForumPostDetailScreen(postId: post.id)),
                      ),
                      onLike: () => repo.toggleLike(post.id),
                      onBookmark: () => repo.toggleBookmark(post.id),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}
