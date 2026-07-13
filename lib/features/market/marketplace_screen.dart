import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/marketplace_product_card.dart';
import '../../data/models/marketplace_model.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  late final TextEditingController _searchController;
  String _selectedProductType = 'all';
  String _selectedCategory = 'all';
  bool _showFilters = false;
  double _priceRange = 100000;
  List<MarketplaceProduct> _products = [];

  final List<String> _productTypes = ['all', 'crop', 'material', 'equipment', 'service'];
  final List<String> _categories = [
    'all',
    'vegetable',
    'grain',
    'seed',
    'fertilizer',
    'tool',
    'equipment',
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    // This would typically come from Firebase
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      // Initialize products
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('Marketplace'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to seller screen to list product
              _showListProductDialog();
            },
            tooltip: 'List Product',
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              // Navigate to cart/orders
            },
            tooltip: 'My Orders',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search and filter header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.filter_list),
                        onPressed: () {
                          setState(() => _showFilters = !_showFilters);
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Product type chips
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _productTypes.length,
                      itemBuilder: (context, index) {
                        final type = _productTypes[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(type == 'all' ? 'All' : type),
                            selected: _selectedProductType == type,
                            onSelected: (_) {
                              setState(() => _selectedProductType = type);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Expanded filter panel
            if (_showFilters)
              _buildFilterPanel()
            else
              const SizedBox.shrink(),

            // Products grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: 8, // Sample count
                itemBuilder: (context, index) {
                  return _buildSampleProductCard(index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPanel() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filters',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // Category filter
          Text(
            'Category',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _categories
                .map((cat) => FilterChip(
                      label: Text(cat == 'all' ? 'All' : cat),
                      selected: _selectedCategory == cat,
                      onSelected: (_) {
                        setState(() => _selectedCategory = cat);
                      },
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),

          // Price filter
          Text(
            'Max Price: XAF ${_priceRange.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Slider(
            value: _priceRange,
            min: 0,
            max: 500000,
            onChanged: (value) {
              setState(() => _priceRange = value);
            },
          ),
          const SizedBox(height: 16),

          // Rating filter
          Text(
            'Rating',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(label: const Text('4.5+'), onSelected: (_) {}),
              FilterChip(label: const Text('4.0+'), onSelected: (_) {}),
              FilterChip(label: const Text('3.5+'), onSelected: (_) {}),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  setState(() => _showFilters = false);
                },
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() => _showFilters = false);
                },
                child: const Text('Apply Filters'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSampleProductCard(int index) {
    final product = MarketplaceProduct(
      productId: 'prod_$index',
      sellerId: 'seller_$index',
      sellerName: 'Farmer ${index + 1}',
      sellerPhotoUrl: '',
      sellerLevel: index % 3 == 0 ? 'expert_farmer' : 'commercial',
      productName: ['Organic Tomatoes', 'Maize Seeds', 'Fertilizer Bag', 'Hoe Tool'][index % 4],
      description: 'High quality produce for your farm',
      price: 5000 + (index * 1000),
      currency: 'XAF',
      productType: ProductType.crop,
      category: _categories[2 + (index % 4)],
      quantity: 20 + (index * 5),
      unit: index % 2 == 0 ? 'kg' : 'bag',
      imageUrls: [],
      listingDate: DateTime.now().subtract(Duration(days: index)),
      isActive: true,
      rating: 4.0 + (index * 0.1),
      reviewsCount: 5 + (index * 2),
      location: 'Yaoundé',
    );

    return MarketplaceProductCard(
      product: product,
      onTap: () {
        _showProductDetails(product);
      },
      onFavorite: () {
        // Add to favorites
      },
    );
  }

  void _showProductDetails(MarketplaceProduct product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  product.productName,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                
                // Seller info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[300],
                          ),
                          child: const Icon(Icons.person),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.sellerName,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                product.sellerLevel,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Contact seller
                          },
                          child: const Text('Contact'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Product info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'XAF ${product.price.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            '${product.rating} (${product.reviewsCount})',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Quantity and location
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Available: ${product.quantity} ${product.unit}'),
                    Text('Location: ${product.location ?? 'Not specified'}'),
                  ],
                ),
                const SizedBox(height: 20),

                // Action buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Add to cart
                    },
                    child: const Text('Add to Cart'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      // Make offer
                    },
                    child: const Text('Make an Offer'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showListProductDialog() {
    showDialog(
      context: context,
      builder: (context) => const _ListProductDialog(),
    );
  }
}

class _ListProductDialog extends StatefulWidget {
  const _ListProductDialog();

  @override
  State<_ListProductDialog> createState() => _ListProductDialogState();
}

class _ListProductDialogState extends State<_ListProductDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _quantityController;
  String _selectedType = 'crop';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _priceController = TextEditingController();
    _quantityController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'List a Product',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Product Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: ['crop', 'material', 'equipment', 'service']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedType = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Price (XAF)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
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
                      // List product
                      Navigator.of(context).pop();
                    },
                    child: const Text('List Product'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
