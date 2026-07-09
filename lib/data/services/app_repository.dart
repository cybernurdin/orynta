import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/leaf_diagnosis.dart';
import '../models/market_listing.dart';
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

  final List<SoilScan> _soilScans = [];
  final List<LeafDiagnosis> _leafDiagnoses = [];
  final List<MarketListing> _listings = [];
  bool _isOnline = true;

  List<SoilScan> get soilScans => List.unmodifiable(_soilScans);
  List<LeafDiagnosis> get leafDiagnoses => List.unmodifiable(_leafDiagnoses);
  List<MarketListing> get listings => List.unmodifiable(_listings);
  bool get isOnline => _isOnline;
  int get pendingSyncCount =>
      _soilScans.where((s) => !s.synced).length;

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
    notifyListeners();
  }

  Future<void> addLeafDiagnosis(LeafDiagnosis diagnosis) async {
    _leafDiagnoses.insert(0, diagnosis);
    await _persistLeaf();
    notifyListeners();
  }

  Future<void> addListing(MarketListing listing) async {
    _listings.insert(0, listing);
    await _persistListings();
    notifyListeners();
  }

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
}
