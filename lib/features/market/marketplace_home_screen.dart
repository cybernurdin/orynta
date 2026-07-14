import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/marketplace_product_card.dart';
import '../../data/models/marketplace_model.dart';
import '../../data/services/app_repository.dart';
import 'create_listing_sheet.dart';
import 'product_detail_screen.dart';
import 'supplier_price_panel.dart';

/// The Marketplace hub: Discover (buyer view of all listings), My Listings
/// (the signed-in farmer's own products), and Suppliers & Prices (the
/// existing input-supplier directory + indicative price trend).
class MarketplaceHomeScreen extends StatefulWidget {
  const MarketplaceHomeScreen({super.key});

  @override
  State<MarketplaceHomeScreen> createState() => _MarketplaceHomeScreenState();
}

class _MarketplaceHomeScreenState extends State<MarketplaceHomeScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 3, vsync: this);
  String _query = '';
  ProductType? _typeFilter;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _typeLabel(dynamic strings, ProductType type) => switch (type) {
        ProductType.crop => strings('typeCrop'),
        ProductType.material => strings('typeMaterial'),
        ProductType.equipment => strings('typeEquipment'),
        ProductType.service => strings('typeService'),
      };

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LocaleProvider>().strings;
    final repo = context.watch<AppRepository>();

    var discoverProducts = repo.marketplaceProducts.where((p) {
      if (_typeFilter != null && p.productType != _typeFilter) return false;
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return p.productName.toLowerCase().contains(q) || p.category.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(strings('marketTitle')),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.forest,
          indicatorColor: AppColors.forest,
          tabs: [
            Tab(text: strings('discover')),
            Tab(text: strings('myListings')),
            Tab(text: strings('suppliers')),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => const CreateListingSheet(),
        ),
        backgroundColor: AppColors.forest,
        icon: const Icon(Icons.add_rounded, color: AppColors.white),
        label: Text(strings('createListing'), style: const TextStyle(color: AppColors.white)),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _DiscoverTab(
            products: discoverProducts,
            typeFilter: _typeFilter,
            onQueryChanged: (v) => setState(() => _query = v),
            onTypeFilterChanged: (t) => setState(() => _typeFilter = t),
            typeLabel: _typeLabel,
            strings: strings,
          ),
          _MyListingsTab(products: repo.myListings, strings: strings),
          const SupplierPricePanel(),
        ],
      ),
    );
  }
}

class _DiscoverTab extends StatelessWidget {
  final List<MarketplaceProduct> products;
  final ProductType? typeFilter;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<ProductType?> onTypeFilterChanged;
  final String Function(dynamic, ProductType) typeLabel;
  final dynamic strings;

  const _DiscoverTab({
    required this.products,
    required this.typeFilter,
    required this.onQueryChanged,
    required this.onTypeFilterChanged,
    required this.typeLabel,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            onChanged: onQueryChanged,
            decoration: InputDecoration(
              hintText: strings('searchMarketplace'),
              prefixIcon: const Icon(Icons.search_rounded),
            ),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            children: [
              ChoiceChip(
                label: Text(strings('allCategories')),
                selected: typeFilter == null,
                onSelected: (_) => onTypeFilterChanged(null),
              ),
              const SizedBox(width: 8),
              ...ProductType.values.map(
                (t) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(typeLabel(strings, t)),
                    selected: typeFilter == t,
                    onSelected: (_) => onTypeFilterChanged(t),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: products.isEmpty
              ? Center(child: Text(strings('noProductsFound'), style: const TextStyle(color: AppColors.grey)))
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.68,
                  ),
                  itemCount: products.length,
                  itemBuilder: (_, i) {
                    final product = products[i];
                    return MarketplaceProductCard(
                      product: product,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _MyListingsTab extends StatelessWidget {
  final List<MarketplaceProduct> products;
  final dynamic strings;
  const _MyListingsTab({required this.products, required this.strings});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(strings('noOwnListings'), style: const TextStyle(color: AppColors.grey), textAlign: TextAlign.center),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.68,
      ),
      itemCount: products.length,
      itemBuilder: (_, i) {
        final product = products[i];
        return MarketplaceProductCard(
          product: product,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
          ),
        );
      },
    );
  }
}
