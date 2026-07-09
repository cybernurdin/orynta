import '../models/supplier.dart';

/// Stands in for the Supplier directory + market data service in
/// Orynta_SRS.md §3.4 (FR-4.1–4.4). Real version queries PostGIS for
/// nearest suppliers and a market-price feed for the trend chart.
class MarketService {
  Future<List<Supplier>> getNearbySuppliers() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const [
      Supplier(
        id: 'sup_1',
        name: 'Bafoussam Agro Inputs',
        region: 'West Region',
        productCategories: ['Fertilizer', 'Fungicide'],
        phone: '+237 6XX XXX 001',
        distanceKm: 4.2,
      ),
      Supplier(
        id: 'sup_2',
        name: 'Cooperative Agro-Ndé',
        region: 'West Region',
        productCategories: ['Seeds', 'Fertilizer'],
        phone: '+237 6XX XXX 002',
        distanceKm: 7.8,
      ),
      Supplier(
        id: 'sup_3',
        name: 'Foumbot Farm Supplies',
        region: 'West Region',
        productCategories: ['Pesticide', 'Tools'],
        phone: '+237 6XX XXX 003',
        distanceKm: 11.5,
      ),
    ];
  }

  /// Indicative regional price trend for FR-4.4, in FCFA per kg.
  Future<Map<String, List<double>>> getPriceTrend(String cropName) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return {
      cropName: const [180, 190, 175, 210, 225, 205, 230],
    };
  }
}
