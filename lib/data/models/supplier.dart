/// Mirrors the `Supplier` entity in Orynta_SRS.md §7 (FR-4.2).
class Supplier {
  final String id;
  final String name;
  final String region;
  final List<String> productCategories;
  final String phone;
  final double distanceKm;

  const Supplier({
    required this.id,
    required this.name,
    required this.region,
    required this.productCategories,
    required this.phone,
    required this.distanceKm,
  });
}
