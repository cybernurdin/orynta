/// The farmer-facing account profile. `farmerType` lets recommendations
/// and content be tuned by experience level, mirroring the persona set in
/// Orynta_SRS.md §1.1 (smallholder, cooperative manager, agronomist, ...).
enum FarmerType { beginner, advanced, commercial, subsistence, organic, agronomist, officer }

class FarmerProfile {
  final String name;
  final String region;
  final String cropFocus;
  final FarmerType farmerType;
  final DateTime joinedAt;

  const FarmerProfile({
    required this.name,
    required this.region,
    required this.cropFocus,
    required this.farmerType,
    required this.joinedAt,
  });

  static FarmerProfile defaults() => FarmerProfile(
        name: 'Mama Ngozi',
        region: 'West Region',
        cropFocus: 'Tomato & maize',
        farmerType: FarmerType.beginner,
        joinedAt: DateTime.now(),
      );

  FarmerProfile copyWith({
    String? name,
    String? region,
    String? cropFocus,
    FarmerType? farmerType,
  }) =>
      FarmerProfile(
        name: name ?? this.name,
        region: region ?? this.region,
        cropFocus: cropFocus ?? this.cropFocus,
        farmerType: farmerType ?? this.farmerType,
        joinedAt: joinedAt,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'region': region,
        'cropFocus': cropFocus,
        'farmerType': farmerType.name,
        'joinedAt': joinedAt.toIso8601String(),
      };

  factory FarmerProfile.fromJson(Map<String, dynamic> json) => FarmerProfile(
        name: json['name'] as String,
        region: json['region'] as String,
        cropFocus: json['cropFocus'] as String,
        farmerType: FarmerType.values.byName(json['farmerType'] as String),
        joinedAt: DateTime.parse(json['joinedAt'] as String),
      );
}
