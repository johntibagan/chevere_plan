import 'package:flutter/foundation.dart';

/// Configuración de cliente. **Solo** valores inyectados en compile-time
/// (`--dart-define-from-file=env/test.env` o `env/.pdn.build.env`).
///
/// Plantillas: `env/test.env.example`, `env/pdn.env.example` → copias en `env/` (gitignored).
///
/// Claves de cliente esperadas (públicas por diseño, protegidas por RLS / cuotas):
/// - `SUPABASE_URL`, `SUPABASE_ANON_KEY` (nunca `service_role`)
/// - `GOOGLE_WEB_CLIENT_ID`
/// - `GOOGLE_MAPS_API_KEY` (Maps SDK + Places + Geocoding)
/// - `GEOAPIFY_API_KEY`, `GEOAPIFY_DAILY_LIMIT` (fallback)
class Env {
  Env._();

  static const String appEnv =
      String.fromEnvironment('APP_ENV', defaultValue: 'test');

  /// Etiqueta corta para el menú ☰ (TEST / BETA).
  static String get appEnvironmentLabel {
    switch (appEnv.trim().toLowerCase()) {
      case 'beta':
      case 'pdn':
        return 'BETA';
      default:
        return 'TEST';
    }
  }

  /// APK de prueba cerrada (PDN). El de desarrollo (`test`) no chequea actualizaciones.
  static bool get isBetaRelease {
    switch (appEnv.trim().toLowerCase()) {
      case 'beta':
      case 'pdn':
        return true;
      default:
        return false;
    }
  }

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');
  static const String googleWebClientId =
      String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
  static const String googleMapsApiKey =
      String.fromEnvironment('GOOGLE_MAPS_API_KEY');
  static const String _googlePlacesDailyLimitRaw =
      String.fromEnvironment('GOOGLE_PLACES_DAILY_LIMIT');
  static const String geoapifyApiKey =
      String.fromEnvironment('GEOAPIFY_API_KEY');
  static const String _geoapifyDailyLimitRaw =
      String.fromEnvironment('GEOAPIFY_DAILY_LIMIT');

  /// Tope diario local de Place Details + Autocomplete + Geocoding (default 80).
  static int get googlePlacesDailyLimit {
    final n = int.tryParse(_googlePlacesDailyLimitRaw.trim());
    if (n == null || n < 1) return 80;
    return n;
  }

  /// Tope diario local de llamadas Geoapify en prueba (default 100).
  static int get geoapifyDailyLimit {
    final n = int.tryParse(_geoapifyDailyLimitRaw.trim());
    if (n == null || n < 1) return 100;
    return n;
  }

  static bool get hasSupabaseConfig =>
      supabaseUrl.trim().isNotEmpty && supabaseAnonKey.trim().isNotEmpty;

  /// Cliente solo habla HTTPS con Supabase (validación de cert del SO).
  static bool get supabaseUrlIsHttps =>
      supabaseUrl.trim().toLowerCase().startsWith('https://');

  static bool get hasGoogleWebClientId => googleWebClientId.trim().isNotEmpty;

  static bool get hasGoogleMapsKey => googleMapsApiKey.trim().isNotEmpty;

  static bool get hasGeoapifyKey => geoapifyApiKey.trim().isNotEmpty;

  /// Service role inyectada por error en `--dart-define-from-file` (cliente).
  static bool get hasInjectedServiceRole {
    const serviceRole = String.fromEnvironment('SUPABASE_SERVICE_ROLE_KEY');
    const serviceRoleAlt = String.fromEnvironment('SUPABASE_SERVICE_ROLE');
    return serviceRole.trim().isNotEmpty || serviceRoleAlt.trim().isNotEmpty;
  }

  /// Mensaje de bootstrap sin revelar nombres de secretos internos.
  static String get missingConfigUserMessage {
    if (kReleaseMode) {
      return 'La app no está configurada correctamente. Reinstálala o contacta soporte.';
    }
    return 'Faltan defines de build: SUPABASE_URL y SUPABASE_ANON_KEY.\n'
        'Copia env/test.env.example → env/test.env y usa '
        '--dart-define-from-file=env/test.env';
  }
}
