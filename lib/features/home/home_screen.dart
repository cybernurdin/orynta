import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/icon_circle.dart';
import '../../core/widgets/offline_banner.dart';
import '../../core/widgets/section_header.dart';
import '../../data/models/leaf_diagnosis.dart';
import '../../data/models/soil_scan.dart';
import '../../data/models/weather_advisory.dart';
import '../../data/services/app_repository.dart';
import '../../data/services/weather_service.dart';
import '../scan/capture_screen.dart';
import '../scan/scan_type.dart';
import 'language_switcher_sheet.dart';

/// Home = the first of Orynta_SRS.md §1.2's core journeys: weather advisory
/// translated into a concrete action, plus one-tap entry into the two scan
/// flows. The language switcher lives in the app bar here per
/// Orynta_Brand_Guide.md §6 — never buried in settings.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  WeatherAdvisory? _advisory;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    final advisory = await _weatherService.getWeeklyAdvisory(region: 'West Region');
    if (mounted) setState(() => _advisory = advisory);
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final strings = locale.strings;
    final repo = context.watch<AppRepository>();

    final recentItems = <_RecentItem>[
      ...repo.soilScans.map((s) => _RecentItem.soil(s)),
      ...repo.leafDiagnoses.map((d) => _RecentItem.leaf(d)),
    ]..sort((a, b) => b.capturedAt.compareTo(a.capturedAt));

    return Scaffold(
      appBar: AppBar(
        title: Text(strings('appName')),
        actions: [
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
        onRefresh: _loadWeather,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (!repo.isOnline) ...[
              OfflineBanner(strings: strings, pendingCount: repo.pendingSyncCount),
              const SizedBox(height: 16),
            ],
            _WeatherCard(advisory: _advisory, strings: strings),
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
            SectionHeader(title: strings('recentScans')),
            const SizedBox(height: 10),
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
              ...recentItems.take(5).map((item) => _RecentTile(item: item, strings: strings)),
          ],
        ),
      ),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  final WeatherAdvisory? advisory;
  final dynamic strings;
  const _WeatherCard({required this.advisory, required this.strings});

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
                '${advisory!.highC.round()}° / ${advisory!.lowC.round()}°',
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
                '${advisory!.rainChancePercent}% rain chance',
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

class _RecentItem {
  final String id;
  final bool isSoil;
  final DateTime capturedAt;
  final double confidence;
  final String title;

  _RecentItem.soil(SoilScan s)
      : id = s.id,
        isSoil = true,
        capturedAt = s.capturedAt,
        confidence = s.confidence,
        title = s.soilType.name;

  _RecentItem.leaf(LeafDiagnosis d)
      : id = d.id,
        isSoil = false,
        capturedAt = d.capturedAt,
        confidence = d.confidence,
        title = d.predictedClass;
}

class _RecentTile extends StatelessWidget {
  final _RecentItem item;
  final dynamic strings;
  const _RecentTile({required this.item, required this.strings});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.confidenceColor(item.confidence);
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.confidenceLow,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.white),
      ),
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(strings('delete')),
          content: Text(strings('deleteScanConfirm')),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(strings('cancel'))),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(strings('confirm'), style: const TextStyle(color: AppColors.confidenceLow)),
            ),
          ],
        ),
      ),
      onDismissed: (_) {
        final repo = context.read<AppRepository>();
        item.isSoil ? repo.removeSoilScan(item.id) : repo.removeLeafDiagnosis(item.id);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          leading: IconCircle(
            icon: item.isSoil ? Icons.grass_rounded : Icons.eco_rounded,
            background: item.isSoil ? AppColors.forest : AppColors.amber,
            size: 40,
          ),
          title: Text(item.title),
          subtitle: Text(
            '${item.capturedAt.hour.toString().padLeft(2, '0')}:${item.capturedAt.minute.toString().padLeft(2, '0')}',
          ),
          trailing: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}
