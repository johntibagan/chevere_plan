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
  });

  final String id;
  final AppRole role;
  final String? displayName;
  final String? avatarUrl;
  final String preferredLocale;
  final String preferredCurrency;

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      role: AppRole.fromDb(json['role'] as String?),
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      preferredLocale: (json['preferred_locale'] as String?) ?? 'es',
      preferredCurrency: (json['preferred_currency'] as String?) ?? 'COP',
    );
  }
}
