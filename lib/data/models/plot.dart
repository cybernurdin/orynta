/// Mirrors the `Plot` entity in Orynta_SRS.md §7.
class Plot {
  final String id;
  final String name;
  final String region;
  final String department;
  final double sizeHa;

  const Plot({
    required this.id,
    required this.name,
    required this.region,
    required this.department,
    required this.sizeHa,
  });
}
