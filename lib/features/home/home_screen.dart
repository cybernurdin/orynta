import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/icon_circle.dart';
import '../../core/widgets/offline_banner.dart';
import '../../core/widgets/section_header.dart';
import '../../data/models/soil_scan.dart';
import '../../data/models/weather_advisory.dart';
import '../../data/services/app_repository.dart';
import '../../data/services/location_service.dart';
import '../../data/services/weather_service.dart';
import '../community/forum_screen.dart';
import '../crops/my_crops_screen.dart';
import '../learn/learn_home_screen.dart';
import '../notifications/notifications_screen.dart';
import '../scan/capture_screen.dart';
import '../scan/scan_type.dart';
import '../support/chat_screen.dart';
import 'language_switcher_sheet.dart';
import 'latest_soil_scan_card.dart';
import 'quick_tips_section.dart';
import 'recent_scan_tile.dart';
import 'scan_history_screen.dart';

/// Home = the first of Orynta_SRS.md §1.2's core journeys: weather advisory
/// translated into a concrete action, plus one-tap entry into the two scan
/// flows. The language switcher lives in the app bar here per
/// Orynta_Brand_Guide.md §6 ("Language switcher always accessible
/// from home, not buried in settings").
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();
  WeatherAdvisory? _advisory;
  WeatherData? _liveWeather;
  String? _resolvedRegion;
  bool _resolvingLocation = false;

  @override
  void initState() {
    super.initState();
    _loadLocationAndWeather();
  }

  Future<void> _loadLocationAndWeather() async {
    setState(() => _resolvingLocation = true);
    final fallbackRegion = context.read<AppRepository>().profile.region;
    var region = fallbackRegion;
    try {
      final position = await _locationService.getCurrentLocation().timeout(const Duration(seconds: 6));
      region = _locationService.resolveRegionName(position.latitude, position.longitude);
      // Best-effort live conditions; the advisory text below stays the
      // stable, template-driven copy regardless of whether this succeeds.
      _weatherService.getWeatherByCoordinates(position.latitude, position.longitude).then((data) {
        if (mounted) setState(() => _liveWeather = data);
      });
    } catch (_) {
      region = fallbackRegion;
    }
    if (mounted) {
      setState(() {
        _resolvedRegion = region;
        _resolvingLocation = false;
      });
    }
    await _loadWeather(region);
  }

  Future<void> _loadWeather([String? region]) async {
    final advisory = await _weatherService.getWeeklyAdvisory(region: region ?? _resolvedRegion ?? 'West Region');
    if (mounted) setState(() => _advisory = advisory);
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final strings = locale.strings;
    final repo = context.watch<AppRepository>();

    final recentItems = <RecentScanItem>[
      ...repo.soilScans.map((s) => RecentScanItem.soil(s)),
      ...repo.leafDiagnoses.map((d) => RecentScanItem.leaf(d)),
    ]..sort((a, b) => b.capturedAt.compareTo(a.capturedAt));

    return Scaffold(
      appBar: AppBar(
        title: Text(strings('appName')),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: repo.unreadNotificationCount > 0,
              label: Text('${repo.unreadNotificationCount}'),
              child: const Icon(Icons.notifications_rounded),
            ),
            tooltip: strings('notifications'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.translate_rounded),
            tooltip: strings('language'),
            onPressed: () => showModalBottomSheet(
              context: context,
              builder: (_) => const LanguageSwitcherSheet(),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadLocationAndWeather,
        child: ListView(
          key: const Key('homeScrollView'),
          padding: const EdgeInsets.all(16),
          children: [
            if (!repo.isOnline) ...[
              OfflineBanner(strings: strings, pendingCount: repo.pendingSyncCount),
              const SizedBox(height: 16),
            ],
            _LocationChip(
              region: _resolvedRegion ?? repo.profile.region,
              resolving: _resolvingLocation,
              onRefresh: _loadLocationAndWeather,
            ),
            const SizedBox(height: 12),
            _WeatherCard(advisory: _advisory, live: _liveWeather, strings: strings),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: Icons.grass_rounded,
                    background: AppColors.forest,
                    label: strings('quickScanSoil'),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CaptureScreen(type: ScanType.soil),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.eco_rounded,
                    background: AppColors.amber,
                    label: strings('quickScanLeaf'),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CaptureScreen(type: ScanType.leaf),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SectionHeader(title: strings('quickOverview')),
            const SizedBox(height: 10),
            _StatsRow(repo: repo, strings: strings),
            const SizedBox(height: 24),
            SectionHeader(title: strings('latestSoilScan')),
            const SizedBox(height: 10),
            LatestSoilScanCard(scan: repo.soilScans.isEmpty ? null : repo.soilScans.first, strings: strings),
            const SizedBox(height: 24),
            const QuickTipsSection(),
            const SizedBox(height: 24),
            if (repo.savedCrops.isNotEmpty) ...[
              Row(
                children: [
                  Expanded(child: SectionHeader(title: strings('savedRecommendations'))),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MyCropsScreen()),
                    ),
                    child: Text(strings('viewAll')),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 76,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: repo.savedCrops
                      .take(8)
                      .map(
                        (c) => Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.moss.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.bookmark_rounded, color: AppColors.forest, size: 16),
                              const SizedBox(width: 8),
                              Text(c.cropName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 24),
            ],
            SectionHeader(title: strings('soilHealthTrends')),
            const SizedBox(height: 10),
            _SoilHealthTrendCard(scans: repo.soilScans, strings: strings),
            const SizedBox(height: 24),
            SectionHeader(title: strings('explore')),
            const SizedBox(height: 10),
            SizedBox(
              height: 104,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _ExploreChip(
                    icon: Icons.bookmark_rounded,
                    label: strings('myCrops'),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MyCropsScreen()),
                    ),
                  ),
                  _ExploreChip(
                    icon: Icons.forum_rounded,
                    label: strings('community'),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ForumScreen()),
                    ),
                  ),
                  _ExploreChip(
                    icon: Icons.calendar_month_rounded,
                    label: strings('plantingGuide'),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LearnHomeScreen()),
                    ),
                  ),
                  _ExploreChip(
                    icon: Icons.support_agent_rounded,
                    label: strings('supportChat'),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ChatScreen()),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: SectionHeader(title: strings('recentScans'))),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ScanHistoryScreen()),
                  ),
                  child: Text(strings('viewAll')),
                ),
              ],
            ),
            if (recentItems.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    strings('noScansYet'),
                    style: const TextStyle(color: AppColors.grey),
                  ),
                ),
              )
            else
              ...recentItems.take(5).map((item) => RecentScanTile(item: item, strings: strings)),
          ],
        ),
      ),
    );
  }
}

class _LocationChip extends StatelessWidget {
  final String region;
  final bool resolving;
  final VoidCallback onRefresh;
  const _LocationChip({required this.region, required this.resolving, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.location_on_rounded, color: AppColors.forest, size: 18),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            region,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        InkWell(
          onTap: resolving ? null : onRefresh,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: resolving
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.forest),
                  )
                : const Icon(Icons.refresh_rounded, color: AppColors.forest, size: 16),
          ),
        ),
      ],
    );
  }
}

class _WeatherCard extends StatelessWidget {
  final WeatherAdvisory? advisory;
  final WeatherData? live;
  final dynamic strings;
  const _WeatherCard({required this.advisory, required this.live, required this.strings});

  @override
  Widget build(BuildContext context) {
    if (advisory == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.forest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.wb_cloudy_rounded, color: AppColors.moss),
              const SizedBox(width: 8),
              Text(
                strings('weatherThisWeek'),
                style: const TextStyle(color: AppColors.moss, fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const Spacer(),
              Text(
                live != null
                    ? '${live!.temperature.round()}°'
                    : '${advisory!.highC.round()}° / ${advisory!.lowC.round()}°',
                style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            advisory!.headline,
            style: const TextStyle(color: AppColors.white, fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            advisory!.advisoryText,
            style: TextStyle(color: AppColors.white.withValues(alpha: 0.9), fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.water_drop_rounded, color: AppColors.moss, size: 16),
              const SizedBox(width: 6),
              Text(
                live != null ? live!.description : '${advisory!.rainChancePercent}% rain chance',
                style: TextStyle(color: AppColors.white.withValues(alpha: 0.85), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final Color background;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.background,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          child: Column(
            children: [
              IconCircle(icon: icon, background: background),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final AppRepository repo;
  final dynamic strings;
  const _StatsRow({required this.repo, required this.strings});

  @override
  Widget build(BuildContext context) {
    final healthScore = repo.healthScorePercent;

    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Icons.camera_alt_rounded,
            value: '${repo.totalScansCount}',
            label: strings('totalScans'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            icon: Icons.eco_rounded,
            value: '${repo.cropsMonitoredCount}',
            label: strings('cropsMonitored'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            icon: Icons.favorite_rounded,
            value: healthScore == null ? '—' : '$healthScore%',
            label: strings('healthScore'),
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatTile({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: AppColors.forest, size: 20),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.grey, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _SoilHealthTrendCard extends StatelessWidget {
  final List<SoilScan> scans;
  final dynamic strings;
  const _SoilHealthTrendCard({required this.scans, required this.strings});

  double _fertilityScore(FertilityBand band) => switch (band) {
        FertilityBand.low => 40,
        FertilityBand.medium => 70,
        FertilityBand.high => 95,
      };

  @override
  Widget build(BuildContext context) {
    final chronological = scans.reversed.toList();
    if (chronological.length < 2) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(strings('notEnoughScanData'), style: const TextStyle(color: AppColors.grey)),
        ),
      );
    }
    final points = chronological.take(10).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
        child: SizedBox(
          height: 140,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: 100,
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    for (var i = 0; i < points.length; i++)
                      FlSpot(i.toDouble(), _fertilityScore(points[i].fertilityBand)),
                  ],
                  isCurved: true,
                  color: AppColors.forest,
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.moss.withValues(alpha: 0.2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExploreChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ExploreChip({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconCircle(icon: icon, background: AppColors.forest, size: 40),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, height: 1.1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
