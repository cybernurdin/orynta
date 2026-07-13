class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? location;
  final String? bio;
  final String userType; // 'farmer', 'buyer', 'extension_officer'
  final bool isEmailVerified;
  final DateTime createdAt;
  final DateTime lastLogin;
  final Map<String, dynamic> stats; // totalScans, recommendationsSaved, etc.

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.location,
    this.bio,
    this.userType = 'farmer',
    this.isEmailVerified = false,
    required this.createdAt,
    required this.lastLogin,
    this.stats = const {},
  });

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? location,
    String? bio,
    String? userType,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? lastLogin,
    Map<String, dynamic>? stats,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      userType: userType ?? this.userType,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      stats: stats ?? this.stats,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      location: json['location'] as String?,
      bio: json['bio'] as String?,
      userType: json['userType'] as String? ?? 'farmer',
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLogin: DateTime.parse(json['lastLogin'] as String),
      stats: (json['stats'] as Map<String, dynamic>?) ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'location': location,
      'bio': bio,
      'userType': userType,
      'isEmailVerified': isEmailVerified,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
      'stats': stats,
    };
  }
}
