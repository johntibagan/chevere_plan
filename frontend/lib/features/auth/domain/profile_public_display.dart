import '../../../core/l10n/display_defaults.dart';

/// Cómo se muestra un perfil en público (reseñas, fotos, ficha, drawer).
abstract final class ProfilePublicDisplay {
  /// `@usuario` o fallback «Usuario» — nunca el nombre del correo.
  static String handle({
    String? username,
    String? fallbackLabel,
  }) {
    final u = username?.trim();
    if (u != null && u.isNotEmpty) {
      return u.startsWith('@') ? u : '@$u';
    }
    return fallbackLabel ?? DisplayDefaults.userDisplayName;
  }

  /// Avatar efectivo: si [useGoogleAvatar] → Google; si no → custom; si no hay, null.
  static String? effectiveAvatarUrl({
    String? customAvatarUrl,
    String? googleAvatarUrl,
    bool useGoogleAvatar = false,
  }) {
    final custom = customAvatarUrl?.trim();
    final google = googleAvatarUrl?.trim();
    if (useGoogleAvatar) {
      if (google != null && google.isNotEmpty) return google;
      return null;
    }
    if (custom != null && custom.isNotEmpty) return custom;
    return null;
  }

  /// Lee embed PostgREST `profiles(...)`.
  static ({String? handle, String? avatarUrl}) fromProfileEmbed(Map? profile) {
    if (profile == null) {
      return (handle: null, avatarUrl: null);
    }
    final username = profile['username'] as String?;
    final useGoogle = switch (profile['use_google_avatar']) {
      bool b => b,
      num n => n != 0,
      String s => s.toLowerCase() == 'true' || s == 't' || s == '1',
      _ => false,
    };
    final avatar = effectiveAvatarUrl(
      customAvatarUrl: profile['avatar_url'] as String?,
      googleAvatarUrl: profile['google_avatar_url'] as String?,
      useGoogleAvatar: useGoogle,
    );
    final h = handle(username: username);
    return (
      handle: h == DisplayDefaults.userDisplayName ? null : h,
      avatarUrl: avatar,
    );
  }

  static const profileEmbedSelect =
      'username, avatar_url, google_avatar_url, use_google_avatar';
}
