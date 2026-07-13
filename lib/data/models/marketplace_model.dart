enum ProductType {
  crop,
  material,
  equipment,
  service,
}

enum UserRoleInMarket {
  buyer,
  seller,
  both,
}

class MarketplaceProduct {
  final String productId;
  final String sellerId;
  final String sellerName;
  final String sellerPhotoUrl;
  final String sellerLevel; // 'expert_farmer', 'commercial', 'beginner'
  final String productName;
  final String description;
  final double price;
  final String currency; // 'XAF', 'USD'
  final ProductType productType;
  final String category; // e.g., 'vegetable', 'grain', 'seed', 'fertilizer', 'tool'
  final int quantity;
  final String unit; // 'kg', 'bag', 'liter', 'piece'
  final List<String> imageUrls;
  final DateTime listingDate;
  final bool isActive;
  final double rating;
  final int reviewsCount;
  final String? location;
  final int viewsCount;

  MarketplaceProduct({
    required this.productId,
    required this.sellerId,
    required this.sellerName,
    required this.sellerPhotoUrl,
    required this.sellerLevel,
    required this.productName,
    required this.description,
    required this.price,
    required this.currency,
    required this.productType,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.imageUrls,
    required this.listingDate,
    required this.isActive,
    required this.rating,
    required this.reviewsCount,
    this.location,
    this.viewsCount = 0,
  });

  factory MarketplaceProduct.fromJson(Map<String, dynamic> json) {
    return MarketplaceProduct(
      productId: json['productId'] as String,
      sellerId: json['sellerId'] as String,
      sellerName: json['sellerName'] as String,
      sellerPhotoUrl: json['sellerPhotoUrl'] as String,
      sellerLevel: json['sellerLevel'] as String,
      productName: json['productName'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      productType: ProductType.values.byName(json['productType'] as String),
      category: json['category'] as String,
      quantity: json['quantity'] as int,
      unit: json['unit'] as String,
      imageUrls: List<String>.from(json['imageUrls'] as List),
      listingDate: DateTime.parse(json['listingDate'] as String),
      isActive: json['isActive'] as bool,
      rating: (json['rating'] as num).toDouble(),
      reviewsCount: json['reviewsCount'] as int,
      location: json['location'] as String?,
      viewsCount: json['viewsCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerPhotoUrl': sellerPhotoUrl,
      'sellerLevel': sellerLevel,
      'productName': productName,
      'description': description,
      'price': price,
      'currency': currency,
      'productType': productType.name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'imageUrls': imageUrls,
      'listingDate': listingDate.toIso8601String(),
      'isActive': isActive,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'location': location,
      'viewsCount': viewsCount,
    };
  }
}

class MarketplaceReview {
  final String reviewId;
  final String productId;
  final String reviewerId;
  final String reviewerName;
  final double rating; // 1-5
  final String comment;
  final DateTime createdAt;

  MarketplaceReview({
    required this.reviewId,
    required this.productId,
    required this.reviewerId,
    required this.reviewerName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory MarketplaceReview.fromJson(Map<String, dynamic> json) {
    return MarketplaceReview(
      reviewId: json['reviewId'] as String,
      productId: json['productId'] as String,
      reviewerId: json['reviewerId'] as String,
      reviewerName: json['reviewerName'] as String,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reviewId': reviewId,
      'productId': productId,
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class MarketplaceTransaction {
  final String transactionId;
  final String buyerId;
  final String sellerId;
  final String productId;
  final int quantity;
  final double totalAmount;
  final String currency;
  final DateTime transactionDate;
  final String status; // 'pending', 'completed', 'cancelled'
  final String? buyerLocation;
  final String? deliveryDate;

  MarketplaceTransaction({
    required this.transactionId,
    required this.buyerId,
    required this.sellerId,
    required this.productId,
    required this.quantity,
    required this.totalAmount,
    required this.currency,
    required this.transactionDate,
    required this.status,
    this.buyerLocation,
    this.deliveryDate,
  });

  factory MarketplaceTransaction.fromJson(Map<String, dynamic> json) {
    return MarketplaceTransaction(
      transactionId: json['transactionId'] as String,
      buyerId: json['buyerId'] as String,
      sellerId: json['sellerId'] as String,
      productId: json['productId'] as String,
      quantity: json['quantity'] as int,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      currency: json['currency'] as String,
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      status: json['status'] as String,
      buyerLocation: json['buyerLocation'] as String?,
      deliveryDate: json['deliveryDate'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'buyerId': buyerId,
      'sellerId': sellerId,
      'productId': productId,
      'quantity': quantity,
      'totalAmount': totalAmount,
      'currency': currency,
      'transactionDate': transactionDate.toIso8601String(),
      'status': status,
      'buyerLocation': buyerLocation,
      'deliveryDate': deliveryDate,
    };
  }
}
