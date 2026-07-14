/// The farmer-facing account profile. `farmerType` lets recommendations
/// and content be tuned by experience level, mirroring the persona set in
/// Orynta_SRS.md §1.1 (smallholder, cooperative manager, agronomist, ...).
enum FarmerType { beginner, advanced, commercial, subsistence, organic, agronomist, officer }

/// Maps a farmer type onto the coarse three-tier badge shown on forum
/// posts and marketplace seller cards — kept in one place so both features
/// agree on who counts as "expert".
extension FarmerLevel on FarmerType {
  String get forumLevel => switch (this) {
        FarmerType.beginner || FarmerType.subsistence => 'beginner',
        FarmerType.advanced || FarmerType.organic => 'intermediate',
        FarmerType.commercial || FarmerType.agronomist || FarmerType.officer => 'expert_farmer',
      };
}

class FarmerProfile {
  final String name;
  final String email;
  final String region;
  final String cropFocus;
  final FarmerType farmerType;
  final DateTime joinedAt;
  final String? photoPath;
  final String bio;

  const FarmerProfile({
    required this.name,
    this.email = '',
    required this.region,
    required this.cropFocus,
    required this.farmerType,
    required this.joinedAt,
    this.photoPath,
    this.bio = '',
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
    String? email,
    String? region,
    String? cropFocus,
    FarmerType? farmerType,
    String? photoPath,
    String? bio,
  }) =>
      FarmerProfile(
        name: name ?? this.name,
        email: email ?? this.email,
        region: region ?? this.region,
        cropFocus: cropFocus ?? this.cropFocus,
        farmerType: farmerType ?? this.farmerType,
        joinedAt: joinedAt,
        photoPath: photoPath ?? this.photoPath,
        bio: bio ?? this.bio,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'region': region,
        'cropFocus': cropFocus,
        'farmerType': farmerType.name,
        'joinedAt': joinedAt.toIso8601String(),
        'photoPath': photoPath,
        'bio': bio,
      };

  factory FarmerProfile.fromJson(Map<String, dynamic> json) => FarmerProfile(
        name: json['name'] as String,
        email: json['email'] as String? ?? '',
        region: json['region'] as String,
        cropFocus: json['cropFocus'] as String,
        farmerType: FarmerType.values.byName(json['farmerType'] as String),
        joinedAt: DateTime.parse(json['joinedAt'] as String),
        photoPath: json['photoPath'] as String?,
        bio: json['bio'] as String? ?? '',
      );
}
