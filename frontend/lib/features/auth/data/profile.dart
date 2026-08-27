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
    this.username,
    this.displayName,
    this.avatarUrl,
    this.googleAvatarUrl,
    this.useGoogleAvatar = false,
    this.usernameChangedAt,
    this.preferredLocale = 'es',
    this.preferredCurrency = 'COP',
    this.preferredDistanceUnit = 'km',
    this.proximityRadiusM = 200,
    this.duplicateSearchRadiusM = 100,
    this.remindPublicSites = false,
  });

  final String id;
  final AppRole role;
  /// Handle público único (sin `@`). Solo display; FKs usan [id].
  final String? username;
  /// Nombre de OAuth / legado; no se muestra en público.
  final String? displayName;
  /// Avatar propio (URL pública).
  final String? avatarUrl;
  final String? googleAvatarUrl;
  final bool useGoogleAvatar;
  /// Último cambio de @usuario (UTC). Cooldown 3 meses.
  final DateTime? usernameChangedAt;
  final String preferredLocale;
  final String preferredCurrency;
  final String preferredDistanceUnit;
  final int proximityRadiusM;
  /// Radio (m) para anti-dupe por pin al guardar. Default 100.
  final int duplicateSearchRadiusM;
  final bool remindPublicSites;

  static const usernameChangeCooldown = Duration(days: 90);

  bool get hasUsername {
    final u = username?.trim();
    return u != null && u.isNotEmpty;
  }

  /// Puede editar el handle: primer set o pasaron 3 meses desde el último cambio.
  bool get canChangeUsername {
    if (!hasUsername) return true;
    final at = usernameChangedAt;
    if (at == null) return false;
    return DateTime.now().toUtc().isAfter(at.toUtc().add(usernameChangeCooldown));
  }

  DateTime? get usernameChangeAvailableAt {
    final at = usernameChangedAt;
    if (at == null) return null;
    return at.toUtc().add(usernameChangeCooldown);
  }

  factory Profile.fromJson(Map<String, dynamic> json) {
    final radius = json['proximity_radius_m'];
    final dupeRadius = json['duplicate_search_radius_m'];
    final changedRaw = json['username_changed_at'] as String?;
    return Profile(
      id: json['id'] as String,
      role: AppRole.fromDb(json['role'] as String?),
      username: json['username'] as String?,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      googleAvatarUrl: json['google_avatar_url'] as String?,
      useGoogleAvatar: json['use_google_avatar'] as bool? ?? false,
      usernameChangedAt:
          changedRaw == null ? null : DateTime.tryParse(changedRaw),
      preferredLocale: (json['preferred_locale'] as String?) ?? 'es',
      preferredCurrency: (json['preferred_currency'] as String?) ?? 'COP',
      preferredDistanceUnit:
          (json['preferred_distance_unit'] as String?) ?? 'km',
      proximityRadiusM: radius is int
          ? radius
          : (radius is num ? radius.toInt() : 200),
      duplicateSearchRadiusM: dupeRadius is int
          ? dupeRadius
          : (dupeRadius is num ? dupeRadius.toInt() : 100),
      remindPublicSites: json['remind_public_sites'] as bool? ?? false,
    );
  }

  Profile copyWith({
    String? username,
    String? avatarUrl,
    String? googleAvatarUrl,
    bool? useGoogleAvatar,
    DateTime? usernameChangedAt,
    String? preferredDistanceUnit,
    int? proximityRadiusM,
    int? duplicateSearchRadiusM,
    bool? remindPublicSites,
  }) {
    return Profile(
      id: id,
      role: role,
      username: username ?? this.username,
      displayName: displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      googleAvatarUrl: googleAvatarUrl ?? this.googleAvatarUrl,
      useGoogleAvatar: useGoogleAvatar ?? this.useGoogleAvatar,
      usernameChangedAt: usernameChangedAt ?? this.usernameChangedAt,
      preferredLocale: preferredLocale,
      preferredCurrency: preferredCurrency,
      preferredDistanceUnit:
          preferredDistanceUnit ?? this.preferredDistanceUnit,
      proximityRadiusM: proximityRadiusM ?? this.proximityRadiusM,
      duplicateSearchRadiusM:
          duplicateSearchRadiusM ?? this.duplicateSearchRadiusM,
      remindPublicSites: remindPublicSites ?? this.remindPublicSites,
    );
  }
}

class UsernameAvailability {
  const UsernameAvailability({
    required this.available,
    this.normalized,
    this.reason = 'ok',
  });

  final bool available;
  final String? normalized;
  final String reason;

  factory UsernameAvailability.fromJson(Map<String, dynamic> json) {
    return UsernameAvailability(
      available: json['available'] as bool? ?? false,
      normalized: json['normalized'] as String?,
      reason: (json['reason'] as String?) ?? 'ok',
    );
  }
}
