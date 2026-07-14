import '../models/farmer_profile.dart';

/// A locally-stored demo account. Stands in for a real backend user record
/// until Firebase (already a dependency, never yet configured with a live
/// project) is connected in a later phase — see LocalAuthService.
class LocalAccount {
  final String email;
  final String passwordHash;
  final String salt;
  final String displayName;
  final FarmerType farmerType;
  final String provider; // 'email' | 'google'
  final DateTime createdAt;

  const LocalAccount({
    required this.email,
    required this.passwordHash,
    required this.salt,
    required this.displayName,
    required this.farmerType,
    required this.provider,
    required this.createdAt,
  });

  LocalAccount copyWith({String? passwordHash, String? salt}) => LocalAccount(
        email: email,
        passwordHash: passwordHash ?? this.passwordHash,
        salt: salt ?? this.salt,
        displayName: displayName,
        farmerType: farmerType,
        provider: provider,
        createdAt: createdAt,
      );

  Map<String, dynamic> toJson() => {
        'email': email,
        'passwordHash': passwordHash,
        'salt': salt,
        'displayName': displayName,
        'farmerType': farmerType.name,
        'provider': provider,
        'createdAt': createdAt.toIso8601String(),
      };

  factory LocalAccount.fromJson(Map<String, dynamic> json) => LocalAccount(
        email: json['email'] as String,
        passwordHash: json['passwordHash'] as String,
        salt: json['salt'] as String,
        displayName: json['displayName'] as String,
        farmerType: FarmerType.values.byName(json['farmerType'] as String),
        provider: json['provider'] as String? ?? 'email',
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
