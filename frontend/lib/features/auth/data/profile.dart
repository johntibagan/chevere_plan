enum AppRole {
  user,
  admin,
  root;

  bool get isStaff => this == AppRole.admin || this == AppRole.root;

  static AppRole fromDb(String? value) {
    switch (value) {
      case 'admin':
        return AppRole.admin;
      case 'root':
        return AppRole.root;
      default:
        return AppRole.user;
    }
  }

  String get dbValue => name;
}

class Profile {
  const Profile({
    required this.id,
    required this.role,
    this.displayName,
    this.avatarUrl,
    this.preferredLocale = 'es',
    this.preferredCurrency = 'COP',
    this.preferredDistanceUnit = 'km',
    this.proximityRadiusM = 200,
    this.remindPublicSites = false,
  });

  final String id;
  final AppRole role;
  final String? displayName;
  final String? avatarUrl;
  final String preferredLocale;
  final String preferredCurrency;
  final String preferredDistanceUnit;
  final int proximityRadiusM;
  final bool remindPublicSites;

  factory Profile.fromJson(Map<String, dynamic> json) {
    final radius = json['proximity_radius_m'];
    return Profile(
      id: json['id'] as String,
      role: AppRole.fromDb(json['role'] as String?),
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      preferredLocale: (json['preferred_locale'] as String?) ?? 'es',
      preferredCurrency: (json['preferred_currency'] as String?) ?? 'COP',
      preferredDistanceUnit:
          (json['preferred_distance_unit'] as String?) ?? 'km',
      proximityRadiusM: radius is int
          ? radius
          : (radius is num ? radius.toInt() : 200),
      remindPublicSites: json['remind_public_sites'] as bool? ?? false,
    );
  }

  Profile copyWith({
    String? preferredDistanceUnit,
    int? proximityRadiusM,
    bool? remindPublicSites,
  }) {
    return Profile(
      id: id,
      role: role,
      displayName: displayName,
      avatarUrl: avatarUrl,
      preferredLocale: preferredLocale,
      preferredCurrency: preferredCurrency,
      preferredDistanceUnit:
          preferredDistanceUnit ?? this.preferredDistanceUnit,
      proximityRadiusM: proximityRadiusM ?? this.proximityRadiusM,
      remindPublicSites: remindPublicSites ?? this.remindPublicSites,
    );
  }
}
