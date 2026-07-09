import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/section_header.dart';
import '../../data/models/market_listing.dart';
import '../../data/models/supplier.dart';
import '../../data/services/app_repository.dart';
import '../../data/services/market_service.dart';
import 'add_listing_sheet.dart';

/// FR-4.1–4.4: supplier directory, farmer listings, indicative price trend.
class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final MarketService _marketService = MarketService();
  List<Supplier> _suppliers = [];
  List<double> _trend = [];

  @override
  void initState() {
    super.initState();
    _marketService.getNearbySuppliers().then((s) {
      if (mounted) setState(() => _suppliers = s);
    });
    _marketService.getPriceTrend('Tomato').then((m) {
      if (mounted) setState(() => _trend = m.values.first);
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LocaleProvider>().strings;
    final listings = context.watch<AppRepository>().listings;

    return Scaffold(
      appBar: AppBar(title: Text(strings('marketTitle'))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => const AddListingSheet(),
        ),
        backgroundColor: AppColors.forest,
        icon: const Icon(Icons.add_rounded, color: AppColors.white),
        label: Text(strings('addListing'), style: const TextStyle(color: AppColors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          SectionHeader(title: strings('myListings')),
          const SizedBox(height: 10),
          if (listings.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(strings('noListings'), style: const TextStyle(color: AppColors.grey)),
              ),
            )
          else
            ...listings.map(
              (l) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const Icon(Icons.eco_rounded, color: AppColors.forest),
                  title: Text('${l.cropName} · ${l.quantity.toStringAsFixed(0)} ${l.unit}'),
                  subtitle: Text(
                    '${strings('readyDate')}: ${l.readyDate.year}-${l.readyDate.month.toString().padLeft(2, '0')}-${l.readyDate.day.toString().padLeft(2, '0')}'
                    ' · ${strings(_statusKey(l.status))}',
                  ),
                  trailing: PopupMenuButton<_ListingAction>(
                    icon: const Icon(Icons.more_vert_rounded, color: AppColors.grey),
                    onSelected: (action) => switch (action) {
                      _ListingAction.edit => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => AddListingSheet(existing: l),
                        ),
                      _ListingAction.delete => _confirmDeleteListing(context, strings, l.id),
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: _ListingAction.edit,
                        child: ListTile(
                          leading: const Icon(Icons.edit_outlined),
                          title: Text(strings('edit')),
                        ),
                      ),
                      PopupMenuItem(
                        value: _ListingAction.delete,
                        child: ListTile(
                          leading: const Icon(Icons.delete_outline_rounded, color: AppColors.confidenceLow),
                          title: Text(strings('delete')),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 24),
          SectionHeader(title: strings('priceTrend')),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
              child: SizedBox(
                height: 160,
                child: _trend.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: [
                                for (var i = 0; i < _trend.length; i++)
                                  FlSpot(i.toDouble(), _trend[i]),
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
          ),
          const SizedBox(height: 24),
          SectionHeader(title: strings('suppliers')),
          const SizedBox(height: 10),
          ..._suppliers.map(
            (s) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const Icon(Icons.storefront_rounded, color: AppColors.forest),
                title: Text(s.name),
                subtitle: Text('${s.productCategories.join(", ")} · ${s.distanceKm.toStringAsFixed(1)} km'),
                trailing: IconButton(
                  icon: const Icon(Icons.call_rounded, color: AppColors.amber),
                  tooltip: strings('contactSupplier'),
                  onPressed: () {},
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _statusKey(ListingStatus status) => switch (status) {
        ListingStatus.active => 'statusActive',
        ListingStatus.pending => 'statusPending',
        ListingStatus.sold => 'statusSold',
      };

  void _confirmDeleteListing(BuildContext context, dynamic strings, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(strings('deleteListing')),
        content: Text(strings('deleteListingConfirm')),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(strings('cancel'))),
          TextButton(
            onPressed: () {
              context.read<AppRepository>().removeListing(id);
              Navigator.of(ctx).pop();
            },
            child: Text(strings('confirm'), style: const TextStyle(color: AppColors.confidenceLow)),
          ),
        ],
      ),
    );
  }
}

enum _ListingAction { edit, delete }
