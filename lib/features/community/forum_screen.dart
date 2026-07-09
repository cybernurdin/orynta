import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/icon_circle.dart';
import '../../core/widgets/section_header.dart';
import '../../data/models/forum_post.dart';
import '../../data/services/app_repository.dart';
import 'forum_post_detail_screen.dart';
import 'new_post_sheet.dart';

enum _SortMode { recent, mostCommented }

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

  String _categoryLabel(dynamic strings, ForumCategory category) => switch (category) {
        ForumCategory.pestControl => strings('categoryPestControl'),
        ForumCategory.soilHealth => strings('categorySoilHealth'),
        ForumCategory.weather => strings('categoryWeather'),
        ForumCategory.market => strings('categoryMarket'),
        ForumCategory.general => strings('categoryGeneral'),
      };

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LocaleProvider>().strings;
    final repo = context.watch<AppRepository>();

    var posts = repo.forumPosts.where((p) => _filter == null || p.category == _filter).toList();
    posts.sort(_sort == _SortMode.recent
        ? (a, b) => b.postedAt.compareTo(a.postedAt)
        : (a, b) => b.comments.length.compareTo(a.comments.length));

    return Scaffold(
      appBar: AppBar(title: Text(strings('community'))),
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
                    label: _categoryLabel(strings, c),
                    selected: _filter == c,
                    onTap: () => setState(() => _filter = c),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
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
          if (posts.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(strings('noForumPosts'), style: const TextStyle(color: AppColors.grey)),
              ),
            )
          else
            ...posts.map(
              (post) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ForumPostDetailScreen(postId: post.id)),
                  ),
                  leading: const IconCircle(icon: Icons.person_rounded, size: 40),
                  title: Text(post.author, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  subtitle: Text(
                    post.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.mode_comment_outlined, size: 16, color: AppColors.grey),
                      const SizedBox(height: 2),
                      Text('${post.comments.length}', style: const TextStyle(fontSize: 12, color: AppColors.grey)),
                    ],
                  ),
                ),
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
