/// Mirrors the `MarketListing` entity in Orynta_SRS.md §7 (FR-4.3).
enum ListingStatus { active, pending, sold }

class MarketListing {
  final String id;
  final String cropName;
  final double quantity;
  final String unit;
  final DateTime readyDate;
  final ListingStatus status;
  final double? priceExpectation;

  const MarketListing({
    required this.id,
    required this.cropName,
    required this.quantity,
    required this.unit,
    required this.readyDate,
    required this.status,
    this.priceExpectation,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'cropName': cropName,
        'quantity': quantity,
        'unit': unit,
        'readyDate': readyDate.toIso8601String(),
        'status': status.name,
        'priceExpectation': priceExpectation,
      };

  factory MarketListing.fromJson(Map<String, dynamic> json) => MarketListing(
        id: json['id'] as String,
        cropName: json['cropName'] as String,
        quantity: (json['quantity'] as num).toDouble(),
        unit: json['unit'] as String,
        readyDate: DateTime.parse(json['readyDate'] as String),
        status: ListingStatus.values.byName(json['status'] as String),
        priceExpectation: (json['priceExpectation'] as num?)?.toDouble(),
      );
}
