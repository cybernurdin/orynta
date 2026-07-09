import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_notification.dart';
import '../models/chat_message.dart';
import '../models/farmer_profile.dart';
import '../models/forum_post.dart';
import '../models/leaf_diagnosis.dart';
import '../models/market_listing.dart';
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
  static const _listingsKey = 'orynta_market_listings';
  static const _profileKey = 'orynta_farmer_profile';
  static const _savedCropsKey = 'orynta_saved_crops';
  static const _forumPostsKey = 'orynta_forum_posts';
  static const _chatKey = 'orynta_chat_messages';
  static const _notificationsKey = 'orynta_notifications';

  final List<SoilScan> _soilScans = [];
  final List<LeafDiagnosis> _leafDiagnoses = [];
  final List<MarketListing> _listings = [];
  final List<SavedCrop> _savedCrops = [];
  final List<ForumPost> _forumPosts = [];
  final List<ChatMessage> _chatMessages = [];
  final List<AppNotification> _notifications = [];
  FarmerProfile _profile = FarmerProfile.defaults();
  bool _isOnline = true;

  List<SoilScan> get soilScans => List.unmodifiable(_soilScans);
  List<LeafDiagnosis> get leafDiagnoses => List.unmodifiable(_leafDiagnoses);
  List<MarketListing> get listings => List.unmodifiable(_listings);
  List<SavedCrop> get savedCrops => List.unmodifiable(_savedCrops);
  List<ForumPost> get forumPosts => List.unmodifiable(_forumPosts);
  List<ChatMessage> get chatMessages => List.unmodifiable(_chatMessages);
  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  FarmerProfile get profile => _profile;
  bool get isOnline => _isOnline;
  int get pendingSyncCount =>
      _soilScans.where((s) => !s.synced).length;
  int get unreadNotificationCount =>
      _notifications.where((n) => !n.read).length;

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

    final listingsJson = prefs.getString(_listingsKey);
    if (listingsJson != null) {
      _listings
        ..clear()
        ..addAll((jsonDecode(listingsJson) as List)
            .map((e) => MarketListing.fromJson(e as Map<String, dynamic>)));
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

  Future<void> addListing(MarketListing listing) async {
    _listings.insert(0, listing);
    await _persistListings();
    notifyListeners();
  }

  Future<void> updateListing(MarketListing listing) async {
    final index = _listings.indexWhere((l) => l.id == listing.id);
    if (index == -1) return;
    _listings[index] = listing;
    await _persistListings();
    notifyListeners();
  }

  Future<void> removeListing(String id) async {
    _listings.removeWhere((l) => l.id == id);
    await _persistListings();
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
          category: ForumCategory.pestControl,
          body: 'Shared experience about organic pest control methods for fall armyworm on maize — neem extract sprayed weekly kept damage low this season.',
          postedAt: DateTime.now().subtract(const Duration(days: 3)),
          comments: [
            ForumComment(
              id: 'forum_seed_1_c1',
              author: 'Grace M.',
              body: 'Tried this too, worked well after heavy rain washed off the first application.',
              postedAt: DateTime.now().subtract(const Duration(days: 2)),
            ),
          ],
        ),
        ForumPost(
          id: 'forum_seed_2',
          author: 'James T.',
          category: ForumCategory.soilHealth,
          body: 'Asked about cassava intercropping techniques to improve soil health between planting cycles.',
          postedAt: DateTime.now().subtract(const Duration(days: 6)),
          comments: const [],
        ),
        ForumPost(
          id: 'forum_seed_3',
          author: 'Sarah K.',
          category: ForumCategory.market,
          body: 'Tomato prices in my area jumped this week — is anyone else seeing the same trend before the rains?',
          postedAt: DateTime.now().subtract(const Duration(days: 8)),
          comments: const [],
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

  Future<void> _persistListings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _listingsKey,
      jsonEncode(_listings.map((e) => e.toJson()).toList()),
    );
  }

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
}
