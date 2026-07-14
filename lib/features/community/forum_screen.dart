import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/forum_post_card.dart';
import '../../core/widgets/section_header.dart';
import '../../data/models/forum_model.dart';
import '../../data/models/forum_post.dart';
import '../../data/services/app_repository.dart';
import 'bookmarks_screen.dart';
import 'forum_post_detail_screen.dart';
import 'new_post_sheet.dart';
import 'top_contributors_screen.dart';

enum _SortMode { recent, mostCommented }

String categoryLabel(dynamic strings, ForumCategory category) => switch (category) {
      ForumCategory.soilManagement => strings('categorySoilManagement'),
      ForumCategory.plantHealth => strings('categoryPlantHealth'),
      ForumCategory.pestControl => strings('categoryPestControl'),
      ForumCategory.technology => strings('categoryTechnology'),
      ForumCategory.successStories => strings('categorySuccessStories'),
    };

/// AgriForum: farmer-to-farmer Q&A, inspired by the SoilLens prototype —
/// ask a question, share an experience, filter by topic.
class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  ForumCategory? _filter;
  _SortMode _sort = _SortMode.recent;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LocaleProvider>().strings;
    final repo = context.watch<AppRepository>();
    final myEmail = repo.profile.email;

    var posts = repo.forumPosts.where((p) {
      if (_filter != null && p.category != _filter) return false;
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return p.title.toLowerCase().contains(q) || p.body.toLowerCase().contains(q);
    }).toList();
    posts.sort(_sort == _SortMode.recent
        ? (a, b) => b.postedAt.compareTo(a.postedAt)
        : (a, b) => b.comments.length.compareTo(a.comments.length));
    final pinned = posts.where((p) => p.isPinned).toList();
    final rest = posts.where((p) => !p.isPinned).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(strings('community')),
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events_outlined),
            tooltip: strings('topContributors'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TopContributorsScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_outline_rounded),
            tooltip: strings('bookmarks'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BookmarksScreen()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => const NewPostSheet(),
        ),
        backgroundColor: AppColors.forest,
        icon: const Icon(Icons.add_rounded, color: AppColors.white),
        label: Text(strings('askQuestion'), style: const TextStyle(color: AppColors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          TextField(
            onChanged: (value) => setState(() => _query = value.trim()),
            decoration: InputDecoration(
              hintText: strings('searchForum'),
              prefixIcon: const Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _CategoryChip(
                  label: strings('allCategories'),
                  selected: _filter == null,
                  onTap: () => setState(() => _filter = null),
                ),
                ...ForumCategory.values.map(
                  (c) => _CategoryChip(
                    label: categoryLabel(strings, c),
                    selected: _filter == c,
                    onTap: () => setState(() => _filter = c),
                  ),
                ),
              ],
            ),
          ),
          if (repo.announcements.isNotEmpty) ...[
            const SizedBox(height: 20),
            SectionHeader(title: strings('announcements')),
            const SizedBox(height: 10),
            ...repo.announcements.map((a) => _AnnouncementCard(announcement: a)),
          ],
          if (pinned.isNotEmpty) ...[
            const SizedBox(height: 20),
            SectionHeader(title: strings('pinnedTopics')),
            const SizedBox(height: 10),
            ...pinned.map(
              (post) => ForumPostCard(
                post: post,
                categoryLabel: categoryLabel(strings, post.category),
                isLiked: post.likedBy.contains(myEmail),
                isBookmarked: repo.bookmarkedPostIds.contains(post.id),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ForumPostDetailScreen(postId: post.id)),
                ),
                onLike: () => repo.toggleLike(post.id),
                onBookmark: () => repo.toggleBookmark(post.id),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: SectionHeader(title: strings('communityPosts'))),
              DropdownButton<_SortMode>(
                value: _sort,
                underline: const SizedBox.shrink(),
                items: [
                  DropdownMenuItem(value: _SortMode.recent, child: Text(strings('mostRecent'))),
                  DropdownMenuItem(value: _SortMode.mostCommented, child: Text(strings('mostCommented'))),
                ],
                onChanged: (v) => setState(() => _sort = v ?? _sort),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (rest.isEmpty && pinned.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(strings('noForumPosts'), style: const TextStyle(color: AppColors.grey)),
              ),
            )
          else
            ...rest.map(
              (post) => ForumPostCard(
                post: post,
                categoryLabel: categoryLabel(strings, post.category),
                isLiked: post.likedBy.contains(myEmail),
                isBookmarked: repo.bookmarkedPostIds.contains(post.id),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ForumPostDetailScreen(postId: post.id)),
                ),
                onLike: () => repo.toggleLike(post.id),
                onBookmark: () => repo.toggleBookmark(post.id),
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _CategoryChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.forest,
        labelStyle: TextStyle(color: selected ? AppColors.white : AppColors.ink),
        backgroundColor: AppColors.white,
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final Announcement announcement;
  const _AnnouncementCard({required this.announcement});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.campaign_rounded, color: AppColors.amber, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(announcement.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(announcement.content, style: const TextStyle(fontSize: 12, color: AppColors.grey, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
