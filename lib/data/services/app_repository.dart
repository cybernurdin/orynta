import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity_log_entry.dart';
import '../models/app_notification.dart';
import '../models/chat_message.dart';
import '../models/farmer_profile.dart';
import '../models/forum_model.dart';
import '../models/forum_post.dart';
import '../models/leaf_diagnosis.dart';
import '../models/marketplace_model.dart';
import '../models/saved_crop.dart';
import '../models/soil_scan.dart';

/// Offline-first local store per Orynta_SRS.md FR-7.1: every capture is
/// written locally first, then marked `synced` once a (simulated) sync
/// round-trip completes. `isOnline` is a manual toggle here rather than a
/// real connectivity check — it lets the app demonstrate the "airplane
/// mode" capture-then-sync flow described in SRS §9.2 without a platform
/// connectivity plugin, and is where that plugin would slot in later.
class AppRepository extends ChangeNotifier {
  static const _soilKey = 'orynta_soil_scans';
  static const _leafKey = 'orynta_leaf_diagnoses';
  static const _productsKey = 'orynta_marketplace_products';
  static const _reviewsKey = 'orynta_marketplace_reviews';
  static const _profileKey = 'orynta_farmer_profile';
  static const _savedCropsKey = 'orynta_saved_crops';
  static const _forumPostsKey = 'orynta_forum_posts';
  static const _chatKey = 'orynta_chat_messages';
  static const _notificationsKey = 'orynta_notifications';
  static const _notificationPrefsKey = 'orynta_notification_prefs';
  static const _announcementsKey = 'orynta_announcements';
  static const _bookmarksKey = 'orynta_forum_bookmarks';

  final List<SoilScan> _soilScans = [];
  final List<LeafDiagnosis> _leafDiagnoses = [];
  final List<MarketplaceProduct> _marketplaceProducts = [];
  final List<MarketplaceReview> _marketplaceReviews = [];
  final List<SavedCrop> _savedCrops = [];
  final List<ForumPost> _forumPosts = [];
  final List<ChatMessage> _chatMessages = [];
  final List<AppNotification> _notifications = [];
  final List<Announcement> _announcements = [];
  final Set<String> _bookmarkedPostIds = {};
  FarmerProfile _profile = FarmerProfile.defaults();
  bool _isOnline = true;
  Map<NotificationType, bool> _notificationPrefs = {
    for (final t in NotificationType.values) t: true,
  };

  List<SoilScan> get soilScans => List.unmodifiable(_soilScans);
  List<LeafDiagnosis> get leafDiagnoses => List.unmodifiable(_leafDiagnoses);
  List<MarketplaceProduct> get marketplaceProducts => List.unmodifiable(_marketplaceProducts);
  List<MarketplaceProduct> get myListings =>
      List.unmodifiable(_marketplaceProducts.where((p) => p.sellerId == _profile.email));
  List<MarketplaceReview> reviewsFor(String productId) =>
      List.unmodifiable(_marketplaceReviews.where((r) => r.productId == productId));
  List<SavedCrop> get savedCrops => List.unmodifiable(_savedCrops);
  List<ForumPost> get forumPosts => List.unmodifiable(_forumPosts);
  List<ChatMessage> get chatMessages => List.unmodifiable(_chatMessages);
  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  List<Announcement> get announcements => List.unmodifiable(_announcements);
  Set<String> get bookmarkedPostIds => Set.unmodifiable(_bookmarkedPostIds);
  FarmerProfile get profile => _profile;
  bool get isOnline => _isOnline;
  int get pendingSyncCount =>
      _soilScans.where((s) => !s.synced).length;
  int get unreadNotificationCount =>
      _notifications.where((n) => !n.read).length;

  // Single source of truth for the stat numbers shown on both Home and
  // Profile, so the two screens can never quietly drift apart.
  int get totalScansCount => _soilScans.length + _leafDiagnoses.length;

  int get cropsMonitoredCount => _soilScans
      .expand((s) => s.recommendations.map((r) => r.cropName))
      .toSet()
      .length;

  int? get healthScorePercent => _soilScans.isEmpty
      ? null
      : (_soilScans.map((s) => s.confidence).reduce((a, b) => a + b) /
              _soilScans.length *
              100)
          .round();

  int get recommendationsSavedCount => _savedCrops.length;

  int get forumContributionsCount =>
      _forumPosts.where((p) => p.userId == _profile.email).length +
      _forumPosts
          .expand((p) => p.comments)
          .where((c) => c.userId == _profile.email)
          .length;

  /// Computed leaderboard — points from posts (3), comments (1), and likes
  /// received (1) — so it can never contradict the actual seeded/created
  /// activity the way a hand-authored list could.
  List<TopContributor> get topContributors {
    final points = <String, int>{};
    final names = <String, String>{};
    final photos = <String, String>{};
    final levels = <String, String>{};
    final postsCount = <String, int>{};
    final commentsCount = <String, int>{};

    void bump(String userId, String name, String photo, String level, int delta) {
      if (userId.isEmpty) return;
      points[userId] = (points[userId] ?? 0) + delta;
      names[userId] = name;
      photos[userId] = photo;
      levels[userId] = level;
    }

    for (final post in _forumPosts) {
      bump(post.userId, post.author, post.userPhotoUrl, post.userLevel, 3 + post.likes);
      postsCount[post.userId] = (postsCount[post.userId] ?? 0) + 1;
      for (final comment in post.comments) {
        bump(comment.userId, comment.author, comment.userPhotoUrl, post.userLevel, 1);
        commentsCount[comment.userId] = (commentsCount[comment.userId] ?? 0) + 1;
      }
    }

    final contributors = points.entries
        .map((e) => TopContributor(
              userId: e.key,
              userName: names[e.key] ?? 'Farmer',
              userPhotoUrl: photos[e.key] ?? '',
              points: e.value,
              postsCount: postsCount[e.key] ?? 0,
              commentsCount: commentsCount[e.key] ?? 0,
              userLevel: levels[e.key] ?? 'beginner',
            ))
        .toList()
      ..sort((a, b) => b.points.compareTo(a.points));
    return contributors.take(20).toList();
  }

  /// Merged, most-recent-first feed for Profile's Activity Log / Recent
  /// Activity — always derived from the real records above, never stored
  /// separately, so it can't fall out of sync with them.
  List<ActivityLogEntry> get activityLog {
    final entries = <ActivityLogEntry>[
      for (final s in _soilScans)
        ActivityLogEntry(
          id: 'activity_soil_${s.id}',
          kind: ActivityKind.soilScan,
          title: 'Soil scan · ${s.soilType.name}',
          at: s.capturedAt,
        ),
      for (final d in _leafDiagnoses)
        ActivityLogEntry(
          id: 'activity_leaf_${d.id}',
          kind: ActivityKind.leafScan,
          title: 'Leaf scan · ${d.predictedClass}',
          at: d.capturedAt,
        ),
      for (final p in _forumPosts.where((p) => p.userId == _profile.email))
        ActivityLogEntry(
          id: 'activity_post_${p.id}',
          kind: ActivityKind.forumPost,
          title: 'Posted in AgriForum',
          at: p.postedAt,
        ),
      for (final p in _forumPosts)
        for (final c in p.comments.where((c) => c.userId == _profile.email))
          ActivityLogEntry(
            id: 'activity_comment_${c.id}',
            kind: ActivityKind.forumComment,
            title: 'Commented in AgriForum',
            at: c.postedAt,
          ),
      for (final m in _chatMessages.where((m) => m.sender == ChatSender.farmer))
        ActivityLogEntry(
          id: 'activity_chat_${m.id}',
          kind: ActivityKind.chatMessage,
          title: 'Messaged the agricultural officer',
          at: m.sentAt,
        ),
      for (final c in _savedCrops)
        ActivityLogEntry(
          id: 'activity_saved_${c.id}',
          kind: ActivityKind.cropSaved,
          title: 'Saved ${c.cropName} recommendation',
          at: c.savedAt,
        ),
      for (final p in _marketplaceProducts.where((p) => p.sellerId == _profile.email))
        ActivityLogEntry(
          id: 'activity_listing_${p.productId}',
          kind: ActivityKind.productListed,
          title: 'Listed ${p.productName} for sale',
          at: p.listingDate,
        ),
    ]..sort((a, b) => b.at.compareTo(a.at));
    return entries.take(30).toList();
  }

  bool notificationEnabled(NotificationType type) => _notificationPrefs[type] ?? true;

  Future<void> setNotificationEnabled(NotificationType type, bool enabled) async {
    _notificationPrefs[type] = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _notificationPrefsKey,
      jsonEncode(_notificationPrefs.map((k, v) => MapEntry(k.name, v))),
    );
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final soilJson = prefs.getString(_soilKey);
    if (soilJson != null) {
      _soilScans
        ..clear()
        ..addAll((jsonDecode(soilJson) as List)
            .map((e) => SoilScan.fromJson(e as Map<String, dynamic>)));
    }

    final leafJson = prefs.getString(_leafKey);
    if (leafJson != null) {
      _leafDiagnoses
        ..clear()
        ..addAll((jsonDecode(leafJson) as List)
            .map((e) => LeafDiagnosis.fromJson(e as Map<String, dynamic>)));
    }

    final productsJson = prefs.getString(_productsKey);
    if (productsJson != null) {
      _marketplaceProducts
        ..clear()
        ..addAll((jsonDecode(productsJson) as List)
            .map((e) => MarketplaceProduct.fromJson(e as Map<String, dynamic>)));
    } else {
      _marketplaceProducts.addAll(_seedMarketplaceProducts());
      await _persistProducts();
    }

    final reviewsJson = prefs.getString(_reviewsKey);
    if (reviewsJson != null) {
      _marketplaceReviews
        ..clear()
        ..addAll((jsonDecode(reviewsJson) as List)
            .map((e) => MarketplaceReview.fromJson(e as Map<String, dynamic>)));
    } else {
      _marketplaceReviews.addAll(_seedMarketplaceReviews());
      await _persistReviews();
    }

    final profileJson = prefs.getString(_profileKey);
    if (profileJson != null) {
      _profile = FarmerProfile.fromJson(jsonDecode(profileJson) as Map<String, dynamic>);
    }

    final savedCropsJson = prefs.getString(_savedCropsKey);
    if (savedCropsJson != null) {
      _savedCrops
        ..clear()
        ..addAll((jsonDecode(savedCropsJson) as List)
            .map((e) => SavedCrop.fromJson(e as Map<String, dynamic>)));
    }

    final forumJson = prefs.getString(_forumPostsKey);
    if (forumJson != null) {
      _forumPosts
        ..clear()
        ..addAll((jsonDecode(forumJson) as List)
            .map((e) => ForumPost.fromJson(e as Map<String, dynamic>)));
    } else {
      _forumPosts.addAll(_seedForumPosts());
      await _persistForum();
    }

    final chatJson = prefs.getString(_chatKey);
    if (chatJson != null) {
      _chatMessages
        ..clear()
        ..addAll((jsonDecode(chatJson) as List)
            .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>)));
    } else {
      _chatMessages.add(ChatMessage(
        id: 'chat_seed',
        sender: ChatSender.officer,
        body: "Hello! I'm your regional agricultural officer. Ask me anything about your soil, crops, or an escalated diagnosis.",
        sentAt: DateTime.now(),
      ));
      await _persistChat();
    }

    final notificationsJson = prefs.getString(_notificationsKey);
    if (notificationsJson != null) {
      _notifications
        ..clear()
        ..addAll((jsonDecode(notificationsJson) as List)
            .map((e) => AppNotification.fromJson(e as Map<String, dynamic>)));
    }

    final notifPrefsJson = prefs.getString(_notificationPrefsKey);
    if (notifPrefsJson != null) {
      final decoded = jsonDecode(notifPrefsJson) as Map<String, dynamic>;
      _notificationPrefs = {
        for (final t in NotificationType.values) t: decoded[t.name] as bool? ?? true,
      };
    }

    final announcementsJson = prefs.getString(_announcementsKey);
    if (announcementsJson != null) {
      _announcements
        ..clear()
        ..addAll((jsonDecode(announcementsJson) as List)
            .map((e) => Announcement.fromJson(e as Map<String, dynamic>)));
    } else {
      _announcements.addAll(_seedAnnouncements());
      await _persistAnnouncements();
    }

    final bookmarksJson = prefs.getString(_bookmarksKey);
    if (bookmarksJson != null) {
      _bookmarkedPostIds
        ..clear()
        ..addAll((jsonDecode(bookmarksJson) as List).map((e) => e as String));
    }

    notifyListeners();
  }

  void setOnline(bool online) {
    _isOnline = online;
    notifyListeners();
    if (online) _syncPending();
  }

  Future<void> addSoilScan(SoilScan scan) async {
    _soilScans.insert(0, _isOnline ? _markSynced(scan) : scan);
    await _persistSoil();
    await _pushNotification(
      type: NotificationType.scanComplete,
      title: 'Soil scan complete',
      body: 'Your soil scan finished analyzing — view your crop recommendations.',
    );
  }

  Future<void> addLeafDiagnosis(LeafDiagnosis diagnosis) async {
    _leafDiagnoses.insert(0, diagnosis);
    await _persistLeaf();
    await _pushNotification(
      type: NotificationType.scanComplete,
      title: 'Leaf diagnosis complete',
      body: 'Your leaf scan finished analyzing — view the diagnosis and treatment.',
    );
  }

  Future<void> removeSoilScan(String id) async {
    _soilScans.removeWhere((s) => s.id == id);
    await _persistSoil();
    notifyListeners();
  }

  Future<void> removeLeafDiagnosis(String id) async {
    _leafDiagnoses.removeWhere((d) => d.id == id);
    await _persistLeaf();
    notifyListeners();
  }

  Future<void> addProduct(MarketplaceProduct product) async {
    _marketplaceProducts.insert(0, product);
    await _persistProducts();
    notifyListeners();
  }

  Future<void> updateProduct(MarketplaceProduct product) async {
    final index = _marketplaceProducts.indexWhere((p) => p.productId == product.productId);
    if (index == -1) return;
    _marketplaceProducts[index] = product;
    await _persistProducts();
    notifyListeners();
  }

  Future<void> removeProduct(String productId) async {
    _marketplaceProducts.removeWhere((p) => p.productId == productId);
    await _persistProducts();
    notifyListeners();
  }

  Future<void> updateProfile(FarmerProfile profile) async {
    _profile = profile;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(_profile.toJson()));
    notifyListeners();
  }

  Future<void> saveCrop(SavedCrop crop) async {
    if (_savedCrops.any((c) => c.cropName == crop.cropName)) return;
    _savedCrops.insert(0, crop);
    await _persistSavedCrops();
    notifyListeners();
  }

  Future<void> removeSavedCrop(String id) async {
    _savedCrops.removeWhere((c) => c.id == id);
    await _persistSavedCrops();
    notifyListeners();
  }

  Future<void> addForumPost(ForumPost post) async {
    _forumPosts.insert(0, post);
    await _persistForum();
    notifyListeners();
  }

  Future<void> removeForumPost(String id) async {
    _forumPosts.removeWhere((p) => p.id == id);
    await _persistForum();
    notifyListeners();
  }

  Future<void> addForumComment(String postId, ForumComment comment) async {
    final index = _forumPosts.indexWhere((p) => p.id == postId);
    if (index == -1) return;
    final post = _forumPosts[index];
    _forumPosts[index] = post.copyWith(comments: [...post.comments, comment]);
    await _persistForum();
    notifyListeners();
    if (post.userId.isNotEmpty && post.userId != comment.userId) {
      await _pushNotification(
        type: NotificationType.forumReply,
        title: 'New reply on your post',
        body: '${comment.author} replied to "${post.title}".',
      );
    }
  }

  Future<void> toggleLike(String postId) async {
    final index = _forumPosts.indexWhere((p) => p.id == postId);
    if (index == -1) return;
    final post = _forumPosts[index];
    final email = _profile.email;
    final likedBy = List<String>.from(post.likedBy);
    if (likedBy.contains(email)) {
      likedBy.remove(email);
    } else {
      likedBy.add(email);
    }
    _forumPosts[index] = post.copyWith(likedBy: likedBy);
    await _persistForum();
    notifyListeners();
  }

  Future<void> togglePin(String postId) async {
    final index = _forumPosts.indexWhere((p) => p.id == postId);
    if (index == -1) return;
    final post = _forumPosts[index];
    _forumPosts[index] = post.copyWith(isPinned: !post.isPinned);
    await _persistForum();
    notifyListeners();
  }

  Future<void> toggleBookmark(String postId) async {
    if (_bookmarkedPostIds.contains(postId)) {
      _bookmarkedPostIds.remove(postId);
    } else {
      _bookmarkedPostIds.add(postId);
    }
    notifyListeners();
    await _persistBookmarks();
  }

  Future<void> sendChatMessage(String body) async {
    _chatMessages.add(ChatMessage(
      id: 'chat_${DateTime.now().microsecondsSinceEpoch}',
      sender: ChatSender.farmer,
      body: body,
      sentAt: DateTime.now(),
    ));
    await _persistChat();
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 900));
    _chatMessages.add(ChatMessage(
      id: 'chat_${DateTime.now().microsecondsSinceEpoch}',
      sender: ChatSender.officer,
      body: "Thanks for the details — I'll review your case and follow up shortly. In the meantime, keep monitoring and avoid applying new treatments.",
      sentAt: DateTime.now(),
    ));
    await _persistChat();
    await _pushNotification(
      type: NotificationType.officerMessage,
      title: 'Message from Agricultural Officer',
      body: 'Your agricultural officer replied to your message.',
    );
  }

  Future<void> markNotificationRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index == -1) return;
    _notifications[index] = _notifications[index].copyWith(read: true);
    await _persistNotifications();
    notifyListeners();
  }

  Future<void> markAllNotificationsRead() async {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(read: true);
    }
    await _persistNotifications();
    notifyListeners();
  }

  Future<void> _pushNotification({
    required NotificationType type,
    required String title,
    required String body,
  }) async {
    if (!notificationEnabled(type)) return;
    _notifications.insert(
      0,
      AppNotification(
        id: 'notif_${DateTime.now().microsecondsSinceEpoch}',
        type: type,
        title: title,
        body: body,
        createdAt: DateTime.now(),
      ),
    );
    await _persistNotifications();
    notifyListeners();
  }

  List<ForumPost> _seedForumPosts() => [
        ForumPost(
          id: 'forum_seed_1',
          author: 'Emmanuel O.',
          userId: 'seed_emmanuel@orynta.demo',
          userLevel: 'expert_farmer',
          title: 'Organic fall armyworm control that actually worked',
          category: ForumCategory.pestControl,
          body: 'Shared experience about organic pest control methods for fall armyworm on maize — neem extract sprayed weekly kept damage low this season.',
          postedAt: DateTime.now().subtract(const Duration(days: 3)),
          isPinned: true,
          likedBy: const ['seed_grace@orynta.demo', 'seed_james@orynta.demo'],
          comments: [
            ForumComment(
              id: 'forum_seed_1_c1',
              author: 'Grace M.',
              userId: 'seed_grace@orynta.demo',
              body: 'Tried this too, worked well after heavy rain washed off the first application.',
              postedAt: DateTime.now().subtract(const Duration(days: 2)),
            ),
          ],
        ),
        ForumPost(
          id: 'forum_seed_2',
          author: 'James T.',
          userId: 'seed_james@orynta.demo',
          userLevel: 'intermediate',
          title: 'Why are my tomato leaves turning yellow?',
          category: ForumCategory.plantHealth,
          body: "I've been growing tomatoes for the first time and noticed the lower leaves are turning yellow from the bottom up. No visible pests. Could this be a nutrient issue?",
          postedAt: DateTime.now().subtract(const Duration(hours: 5)),
          likedBy: const ['seed_emmanuel@orynta.demo'],
          comments: [
            ForumComment(
              id: 'forum_seed_2_c1',
              author: 'Sarah K.',
              userId: 'seed_sarah@orynta.demo',
              body: 'Sounds like nitrogen deficiency — try a light nitrogen feed and see if new growth comes in greener.',
              postedAt: DateTime.now().subtract(const Duration(hours: 3)),
            ),
          ],
        ),
        ForumPost(
          id: 'forum_seed_3',
          author: 'Sarah K.',
          userId: 'seed_sarah@orynta.demo',
          userLevel: 'expert_farmer',
          title: 'Any good apps for tracking rainfall and planting windows?',
          category: ForumCategory.technology,
          body: "I've been logging rainfall by hand for years — is anyone using an app alongside Orynta that's actually worth the switch?",
          postedAt: DateTime.now().subtract(const Duration(days: 8)),
          comments: const [],
        ),
        ForumPost(
          id: 'forum_seed_4',
          author: 'Grace M.',
          userId: 'seed_grace@orynta.demo',
          userLevel: 'beginner',
          title: 'Cassava intercropping to improve soil health',
          category: ForumCategory.soilManagement,
          body: 'Asked about cassava intercropping techniques to improve soil health between planting cycles — what has worked for others here?',
          postedAt: DateTime.now().subtract(const Duration(days: 6)),
          comments: const [],
        ),
        ForumPost(
          id: 'forum_seed_5',
          author: 'Paul B.',
          userId: 'seed_paul@orynta.demo',
          userLevel: 'intermediate',
          title: 'Anyone using a moisture sensor app alongside Orynta?',
          category: ForumCategory.technology,
          body: 'Curious whether others are pairing a cheap soil moisture sensor with their scans for extra confidence before big planting decisions.',
          postedAt: DateTime.now().subtract(const Duration(days: 1)),
          comments: const [],
        ),
        ForumPost(
          id: 'forum_seed_6',
          author: 'Grace M.',
          userId: 'seed_grace@orynta.demo',
          userLevel: 'beginner',
          title: 'First cocoa harvest doubled after soil testing',
          category: ForumCategory.successStories,
          body: 'Switched to testing soil before each planting season two years ago — this year\'s cocoa harvest nearly doubled versus our old guesswork approach.',
          postedAt: DateTime.now().subtract(const Duration(days: 10)),
          likedBy: const ['seed_emmanuel@orynta.demo', 'seed_james@orynta.demo', 'seed_sarah@orynta.demo'],
          comments: const [],
        ),
      ];

  List<Announcement> _seedAnnouncements() => [
        Announcement(
          announcementId: 'announce_webinar_1',
          title: 'Free webinar: Sustainable farming practices',
          content: 'Join our regional agricultural officers for a free live session on sustainable farming techniques for the upcoming season.',
          publishedAt: DateTime.now().subtract(const Duration(days: 2)),
          eventDate: DateTime.now().add(const Duration(days: 3)),
          category: 'webinar',
        ),
        Announcement(
          announcementId: 'announce_update_1',
          title: 'New: Detailed leaf health scoring',
          content: 'Leaf scans now include a health score and step-by-step recommendations, matching the detail already available in soil scans.',
          publishedAt: DateTime.now().subtract(const Duration(days: 5)),
          category: 'update',
        ),
      ];

  SoilScan _markSynced(SoilScan scan) => SoilScan(
        id: scan.id,
        source: scan.source,
        capturedAt: scan.capturedAt,
        soilType: scan.soilType,
        fertilityBand: scan.fertilityBand,
        confidence: scan.confidence,
        modelVersion: scan.modelVersion,
        imagePath: scan.imagePath,
        recommendations: scan.recommendations,
        synced: true,
      );

  Future<void> _syncPending() async {
    if (_soilScans.every((s) => s.synced)) return;
    await Future.delayed(const Duration(milliseconds: 800));
    for (var i = 0; i < _soilScans.length; i++) {
      if (!_soilScans[i].synced) {
        _soilScans[i] = _markSynced(_soilScans[i]);
      }
    }
    await _persistSoil();
    notifyListeners();
  }

  Future<void> _persistSoil() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _soilKey,
      jsonEncode(_soilScans.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> _persistLeaf() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _leafKey,
      jsonEncode(_leafDiagnoses.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> _persistProducts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _productsKey,
      jsonEncode(_marketplaceProducts.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> _persistReviews() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _reviewsKey,
      jsonEncode(_marketplaceReviews.map((e) => e.toJson()).toList()),
    );
  }

  List<MarketplaceProduct> _seedMarketplaceProducts() {
    final now = DateTime.now();
    return [
      MarketplaceProduct(
        productId: 'product_seed_1',
        sellerId: 'seed_emmanuel@orynta.demo',
        sellerName: 'Emmanuel O.',
        sellerPhotoUrl: '',
        sellerLevel: 'expert_farmer',
        productName: 'Fresh tomatoes',
        description: 'Vine-ripened tomatoes, harvested this week. Good for retail or processing.',
        price: 800,
        currency: 'XAF',
        productType: ProductType.crop,
        category: 'Vegetable',
        quantity: 200,
        unit: 'kg',
        imageUrls: const [],
        listingDate: now.subtract(const Duration(days: 2)),
        isActive: true,
        rating: 4.6,
        reviewsCount: 2,
        location: 'West Region',
      ),
      MarketplaceProduct(
        productId: 'product_seed_2',
        sellerId: 'seed_grace@orynta.demo',
        sellerName: 'Grace M.',
        sellerPhotoUrl: '',
        sellerLevel: 'beginner',
        productName: 'Dried maize (shelled)',
        description: 'Well-dried, shelled maize ready for storage or milling.',
        price: 15000,
        currency: 'XAF',
        productType: ProductType.crop,
        category: 'Grain',
        quantity: 50,
        unit: 'bag',
        imageUrls: const [],
        listingDate: now.subtract(const Duration(days: 6)),
        isActive: true,
        rating: 4.2,
        reviewsCount: 1,
        location: 'Centre Region',
      ),
      MarketplaceProduct(
        productId: 'product_seed_3',
        sellerId: 'seed_supplier_agroplus',
        sellerName: 'AgroPlus Supplies',
        sellerPhotoUrl: '',
        sellerLevel: 'expert_farmer',
        productName: 'NPK 20-10-10 fertilizer',
        description: 'General-purpose NPK fertilizer, suitable for maize, vegetables, and tomatoes.',
        price: 22000,
        currency: 'XAF',
        productType: ProductType.material,
        category: 'Fertilizer',
        quantity: 30,
        unit: 'bag',
        imageUrls: const [],
        listingDate: now.subtract(const Duration(days: 4)),
        isActive: true,
        rating: 4.8,
        reviewsCount: 3,
        location: 'Littoral Region',
      ),
      MarketplaceProduct(
        productId: 'product_seed_4',
        sellerId: 'seed_supplier_agroplus',
        sellerName: 'AgroPlus Supplies',
        sellerPhotoUrl: '',
        sellerLevel: 'expert_farmer',
        productName: 'Certified maize seed (10kg)',
        description: 'Disease-resistant hybrid maize seed, certified for this growing zone.',
        price: 9500,
        currency: 'XAF',
        productType: ProductType.material,
        category: 'Seed',
        quantity: 40,
        unit: 'bag',
        imageUrls: const [],
        listingDate: now.subtract(const Duration(days: 9)),
        isActive: true,
        rating: 4.5,
        reviewsCount: 2,
        location: 'Littoral Region',
      ),
      MarketplaceProduct(
        productId: 'product_seed_5',
        sellerId: 'seed_supplier_toolhub',
        sellerName: 'ToolHub Cameroon',
        sellerPhotoUrl: '',
        sellerLevel: 'commercial',
        productName: 'Manual knapsack sprayer (16L)',
        description: 'Durable manual sprayer for pesticide and foliar fertilizer application.',
        price: 18000,
        currency: 'XAF',
        productType: ProductType.equipment,
        category: 'Tool',
        quantity: 12,
        unit: 'piece',
        imageUrls: const [],
        listingDate: now.subtract(const Duration(days: 12)),
        isActive: true,
        rating: 4.3,
        reviewsCount: 1,
        location: 'Centre Region',
      ),
      MarketplaceProduct(
        productId: 'product_seed_6',
        sellerId: 'seed_supplier_toolhub',
        sellerName: 'ToolHub Cameroon',
        sellerPhotoUrl: '',
        sellerLevel: 'commercial',
        productName: 'Solar-powered irrigation pump',
        description: 'Small-scale solar pump, suitable for plots up to 2 hectares.',
        price: 185000,
        currency: 'XAF',
        productType: ProductType.equipment,
        category: 'Equipment',
        quantity: 3,
        unit: 'piece',
        imageUrls: const [],
        listingDate: now.subtract(const Duration(days: 15)),
        isActive: true,
        rating: 4.9,
        reviewsCount: 4,
        location: 'Centre Region',
      ),
      MarketplaceProduct(
        productId: 'product_seed_7',
        sellerId: 'seed_paul@orynta.demo',
        sellerName: 'Paul B.',
        sellerPhotoUrl: '',
        sellerLevel: 'intermediate',
        productName: 'Soil testing & land prep service',
        description: 'On-site soil sampling and land preparation for the upcoming planting season.',
        price: 25000,
        currency: 'XAF',
        productType: ProductType.service,
        category: 'Service',
        quantity: 1,
        unit: 'piece',
        imageUrls: const [],
        listingDate: now.subtract(const Duration(days: 3)),
        isActive: true,
        rating: 4.4,
        reviewsCount: 1,
        location: 'Northwest Region',
      ),
      MarketplaceProduct(
        productId: 'product_seed_8',
        sellerId: 'seed_sarah@orynta.demo',
        sellerName: 'Sarah K.',
        sellerPhotoUrl: '',
        sellerLevel: 'expert_farmer',
        productName: 'Cassava tubers (fresh)',
        description: 'Freshly harvested cassava, sold by the bag.',
        price: 12000,
        currency: 'XAF',
        productType: ProductType.crop,
        category: 'Root crop',
        quantity: 25,
        unit: 'bag',
        imageUrls: const [],
        listingDate: now.subtract(const Duration(days: 1)),
        isActive: true,
        rating: 4.1,
        reviewsCount: 1,
        location: 'South Region',
      ),
      MarketplaceProduct(
        productId: 'product_seed_9',
        sellerId: 'seed_ngozi@orynta.demo',
        sellerName: 'Mama Ngozi',
        sellerPhotoUrl: '',
        sellerLevel: 'beginner',
        productName: 'Ripe plantains',
        description: 'Farm-fresh plantains, ready for market.',
        price: 6000,
        currency: 'XAF',
        productType: ProductType.crop,
        category: 'Fruit',
        quantity: 60,
        unit: 'bunch',
        imageUrls: const [],
        listingDate: now.subtract(const Duration(hours: 20)),
        isActive: true,
        rating: 0,
        reviewsCount: 0,
        location: 'West Region',
      ),
      MarketplaceProduct(
        productId: 'product_seed_10',
        sellerId: 'seed_ngozi@orynta.demo',
        sellerName: 'Mama Ngozi',
        sellerPhotoUrl: '',
        sellerLevel: 'beginner',
        productName: 'Groundnuts (shelled)',
        description: 'Clean, hand-shelled groundnuts from this season\'s harvest.',
        price: 9000,
        currency: 'XAF',
        productType: ProductType.crop,
        category: 'Legume',
        quantity: 15,
        unit: 'bag',
        imageUrls: const [],
        listingDate: now.subtract(const Duration(days: 5)),
        isActive: true,
        rating: 0,
        reviewsCount: 0,
        location: 'West Region',
      ),
    ];
  }

  List<MarketplaceReview> _seedMarketplaceReviews() => [
        MarketplaceReview(
          reviewId: 'review_seed_1',
          productId: 'product_seed_1',
          reviewerId: 'seed_james@orynta.demo',
          reviewerName: 'James T.',
          rating: 5,
          comment: 'Great quality tomatoes, arrived fresh as described.',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        MarketplaceReview(
          reviewId: 'review_seed_2',
          productId: 'product_seed_3',
          reviewerId: 'seed_grace@orynta.demo',
          reviewerName: 'Grace M.',
          rating: 5,
          comment: "Fast delivery and the fertilizer made a visible difference in two weeks.",
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        MarketplaceReview(
          reviewId: 'review_seed_3',
          productId: 'product_seed_6',
          reviewerId: 'seed_paul@orynta.demo',
          reviewerName: 'Paul B.',
          rating: 4,
          comment: 'Works well, installation guide could be clearer.',
          createdAt: DateTime.now().subtract(const Duration(days: 8)),
        ),
      ];

  Future<void> _persistSavedCrops() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _savedCropsKey,
      jsonEncode(_savedCrops.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> _persistForum() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _forumPostsKey,
      jsonEncode(_forumPosts.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> _persistChat() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _chatKey,
      jsonEncode(_chatMessages.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> _persistNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _notificationsKey,
      jsonEncode(_notifications.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> _persistAnnouncements() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _announcementsKey,
      jsonEncode(_announcements.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> _persistBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_bookmarksKey, jsonEncode(_bookmarkedPostIds.toList()));
  }
}
