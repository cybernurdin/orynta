import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/section_header.dart';
import '../../data/models/supplier.dart';
import '../../data/services/market_service.dart';

/// Supplier directory + indicative price trend — the useful part of the
/// old single-purpose MarketScreen, kept as its own panel inside the new
/// Marketplace hub rather than folded into product listings.
class SupplierPricePanel extends StatefulWidget {
  const SupplierPricePanel({super.key});

  @override
  State<SupplierPricePanel> createState() => _SupplierPricePanelState();
}

class _SupplierPricePanelState extends State<SupplierPricePanel> {
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

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
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
    );
  }
}
