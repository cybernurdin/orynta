import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/forum_post_card.dart';
import '../../data/models/forum_model.dart';

class CommunityForumScreen extends StatefulWidget {
  const CommunityForumScreen({super.key});

  @override
  State<CommunityForumScreen> createState() => _CommunityForumScreenState();
}

class _CommunityForumScreenState extends State<CommunityForumScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final TextEditingController _searchController;
  String _selectedCategory = 'all';
  List<ForumPost> _posts = [];
  List<Announcement> _announcements = [];
  List<TopContributor> _topContributors = [];
  bool _isLoading = true;

  final List<String> _categories = [
    'all',
    'soil_management',
    'plant_health',
    'pest_control',
    'technology',
    'success_stories',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController = TextEditingController();
    _loadForumData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadForumData() async {
    // This would typically come from Firebase
    await Future.delayed(const Duration(milliseconds: 500));
    
    setState(() {
      _isLoading = false;
      // Sample data initialization would happen here
    });
  }

  void _filterByCategory(String category) {
    setState(() => _selectedCategory = category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('Community Forum'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to create post screen
              _showCreatePostDialog();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Posts'),
            Tab(text: 'Announcements'),
            Tab(text: 'Top Contributors'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPostsTab(context),
          _buildAnnouncementsTab(context),
          _buildContributorsTab(context),
        ],
      ),
    );
  }

  Widget _buildPostsTab(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search posts...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),

        // Category filter chips
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final label = category == 'all'
                  ? 'All'
                  : category.replaceAll('_', ' ').toUpperCase();

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(label),
                  selected: _selectedCategory == category,
                  onSelected: (_) => _filterByCategory(category),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // Posts list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 5, // Sample count
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildSamplePostCard(index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAnnouncementsTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _AnnouncementCard(
          title: 'Free Webinar: Sustainable Farming',
          subtitle: 'July 15, 2025 at 2:00 PM',
          description: 'Join our expert farmers for a discussion on sustainable agriculture practices.',
          icon: Icons.event,
          color: Colors.blue,
        ),
        const SizedBox(height: 12),
        _AnnouncementCard(
          title: 'New Pest Alert: Armyworm in Region',
          subtitle: 'Updated: July 10, 2025',
          description: 'Fall armyworm detected in several farms. Recommend immediate action.',
          icon: Icons.warning,
          color: Colors.red,
        ),
        const SizedBox(height: 12),
        _AnnouncementCard(
          title: 'Marketplace Feature Released',
          subtitle: 'July 1, 2025',
          description: 'Buy and sell directly with other farmers and suppliers.',
          icon: Icons.shopping_bag,
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildContributorsTab(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _TopContributorCard(
            rank: index + 1,
            name: 'Farmer ${index + 1}',
            level: index % 3 == 0
                ? 'Expert Farmer'
                : index % 3 == 1
                    ? 'Intermediate'
                    : 'Beginner',
            points: 1000 - (index * 50),
            posts: 20 - index,
            comments: 40 - (index * 2),
          ),
        );
      },
    );
  }

  Widget _buildSamplePostCard(int index) {
    // Sample post data
    final posts = [
      ForumPost(
        postId: 'post_$index',
        userId: 'user_$index',
        userName: 'Farmer ${index + 1}',
        userPhotoUrl: '',
        userLevel: index % 2 == 0 ? 'expert_farmer' : 'beginner',
        title: 'Why are my tomato leaves turning yellow?',
        content:
            'I\'ve been growing tomatoes for the first time and noticed the lower leaves are turning yellow. What could be causing this?',
        category: _categories[index % (_categories.length - 1) + 1],
        createdAt: DateTime.now().subtract(Duration(hours: index)),
        likes: 15 + (index * 5),
        comments: 3 + index,
        likedBy: [],
        isPinned: index == 0,
      ),
    ];

    return ForumPostCard(
      post: posts[0],
      onTap: () {
        // Show post details
      },
      onLike: () {
        // Like post
      },
      onBookmark: () {
        // Bookmark post
      },
      isLiked: false,
      isBookmarked: false,
    );
  }

  void _showCreatePostDialog() {
    showDialog(
      context: context,
      builder: (context) => _CreatePostDialog(
        categories: _categories.where((c) => c != 'all').toList(),
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;

  const _AnnouncementCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(icon, color: color),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopContributorCard extends StatelessWidget {
  final int rank;
  final String name;
  final String level;
  final int points;
  final int posts;
  final int comments;

  const _TopContributorCard({
    required this.rank,
    required this.name,
    required this.level,
    required this.points,
    required this.posts,
    required this.comments,
  });

  @override
  Widget build(BuildContext context) {
    final levelColor = level == 'Expert Farmer'
        ? const Color(0xFF4CAF50)
        : level == 'Intermediate'
            ? const Color(0xFFFFC107)
            : const Color(0xFF2196F3);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: levelColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      level,
                      style: TextStyle(
                        color: levelColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$points pts',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$posts posts • $comments comments',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CreatePostDialog extends StatefulWidget {
  final List<String> categories;

  const _CreatePostDialog({required this.categories});

  @override
  State<_CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<_CreatePostDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  String _selectedCategory = '';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _selectedCategory = widget.categories[0];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create a Post',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: widget.categories
                  .map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(cat.replaceAll('_', ' ')),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                }
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // Create post
                    Navigator.of(context).pop();
                  },
                  child: const Text('Post'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
