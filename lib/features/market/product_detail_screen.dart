import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/icon_circle.dart';
import '../../core/widgets/section_header.dart';
import '../../data/models/marketplace_model.dart';
import '../../data/services/app_repository.dart';
import '../support/chat_screen.dart';
import 'create_listing_sheet.dart';

class ProductDetailScreen extends StatelessWidget {
  final MarketplaceProduct product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LocaleProvider>().strings;
    final repo = context.watch<AppRepository>();
    final isOwner = product.sellerId == repo.profile.email;
    final reviews = repo.reviewsFor(product.productId);

    return Scaffold(
      appBar: AppBar(
        title: Text(product.productName),
        actions: isOwner
            ? [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => CreateListingSheet(existing: product),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.confidenceLow),
                  onPressed: () => _confirmDelete(context, strings, repo),
                ),
              ]
            : null,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SizedBox(
            height: 180,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: product.imageUrls.isNotEmpty
                  ? Image.network(product.imageUrls.first, fit: BoxFit.cover, errorBuilder: (_, _, _) => _placeholder())
                  : _placeholder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${product.currency} ${product.price.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.forest, fontSize: 26),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: product.isActive ? AppColors.forest : AppColors.grey,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  product.isActive ? strings('inStock') : strings('statusSold'),
                  style: const TextStyle(color: AppColors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('${product.quantity} ${product.unit} · ${product.category}', style: const TextStyle(color: AppColors.grey)),
          const SizedBox(height: 16),
          if (product.description.isNotEmpty) ...[
            SectionHeader(title: strings('description')),
            const SizedBox(height: 8),
            Text(product.description, style: const TextStyle(fontSize: 14, height: 1.4)),
            const SizedBox(height: 20),
          ],
          SectionHeader(title: 'Seller'),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: const IconCircle(icon: Icons.person_rounded),
              title: Text(product.sellerName, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(
                '${product.location ?? '—'} · ★ ${product.rating.toStringAsFixed(1)} (${product.reviewsCount})',
                style: const TextStyle(fontSize: 12, color: AppColors.grey),
              ),
              trailing: isOwner
                  ? null
                  : OutlinedButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ChatScreen()),
                      ),
                      child: Text(strings('contactSeller')),
                    ),
            ),
          ),
          if (reviews.isNotEmpty) ...[
            const SizedBox(height: 20),
            SectionHeader(title: strings('reviews')),
            const SizedBox(height: 10),
            ...reviews.map(
              (r) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(r.reviewerName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          const Spacer(),
                          Row(
                            children: List.generate(
                              5,
                              (i) => Icon(
                                i < r.rating.round() ? Icons.star_rounded : Icons.star_border_rounded,
                                size: 14,
                                color: AppColors.amber,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(r.comment, style: const TextStyle(fontSize: 13, height: 1.3)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _placeholder() => const ColoredBox(
        color: Color(0xFFE7EAE2),
        child: Center(child: Icon(Icons.image_outlined, size: 48, color: AppColors.grey)),
      );

  void _confirmDelete(BuildContext context, dynamic strings, AppRepository repo) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(strings('deleteListing')),
        content: Text(strings('deleteListingConfirm')),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(strings('cancel'))),
          TextButton(
            onPressed: () {
              repo.removeProduct(product.productId);
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: Text(strings('confirm'), style: const TextStyle(color: AppColors.confidenceLow)),
          ),
        ],
      ),
    );
  }
}
