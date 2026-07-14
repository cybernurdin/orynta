import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../data/models/marketplace_model.dart';
import 'icon_circle.dart';

class MarketplaceProductCard extends StatelessWidget {
  final MarketplaceProduct product;
  final VoidCallback onTap;
  final VoidCallback? onFavorite;
  final bool isFavorited;

  const MarketplaceProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.onFavorite,
    this.isFavorited = false,
  });

  Color get _typeColor => switch (product.productType) {
        ProductType.crop => AppColors.forest,
        ProductType.material => AppColors.amber,
        ProductType.equipment => AppColors.grey,
        ProductType.service => AppColors.moss,
      };

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 130,
                  width: double.infinity,
                  child: product.imageUrls.isNotEmpty
                      ? Image.network(
                          product.imageUrls[0],
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _placeholder(),
                        )
                      : _placeholder(),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: product.isActive ? AppColors.forest : AppColors.grey, borderRadius: BorderRadius.circular(4)),
                    child: Text(
                      product.isActive ? 'In stock' : 'Sold out',
                      style: const TextStyle(color: AppColors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                if (onFavorite != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onFavorite,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.white),
                        child: Icon(
                          isFavorited ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                          color: isFavorited ? AppColors.confidenceLow : AppColors.grey,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.productName,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (product.sellerPhotoUrl.isEmpty)
                        const IconCircle(icon: Icons.person_rounded, size: 22)
                      else
                        ClipOval(
                          child: Image.network(
                            product.sellerPhotoUrl,
                            width: 22,
                            height: 22,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const IconCircle(icon: Icons.person_rounded, size: 22),
                          ),
                        ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          product.sellerName,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 14, color: AppColors.amber),
                          const SizedBox(width: 4),
                          Text(product.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          Text(' (${product.reviewsCount})', style: const TextStyle(fontSize: 11, color: AppColors.grey)),
                        ],
                      ),
                      Text('${product.quantity} ${product.unit}', style: const TextStyle(fontSize: 11, color: AppColors.grey, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${product.currency} ${product.price.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.forest),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: _typeColor, borderRadius: BorderRadius.circular(4)),
                        child: Text(
                          product.category,
                          style: const TextStyle(fontSize: 9, color: AppColors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => const ColoredBox(
        color: Color(0xFFE7EAE2),
        child: Center(child: Icon(Icons.image_outlined, size: 36, color: AppColors.grey)),
      );
}
