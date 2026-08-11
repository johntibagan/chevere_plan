import 'package:flutter/foundation.dart';

/// Configuración de cliente. **Solo** valores inyectados en compile-time
/// (`--dart-define` / `--dart-define-from-file`).
///
/// No empaquetar `.env` como asset: acaba en el APK/IPA y es trivial de extraer.
///
/// Claves de cliente esperadas (públicas por diseño, protegidas por RLS / cuotas):
/// - `SUPABASE_URL`, `SUPABASE_ANON_KEY` (nunca `service_role`)
/// - `GOOGLE_WEB_CLIENT_ID`
/// - `GEOAPIFY_API_KEY`, `GEOAPIFY_DAILY_LIMIT`
class Env {
  Env._();

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');
  static const String googleWebClientId =
      String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
  static const String geoapifyApiKey =
      String.fromEnvironment('GEOAPIFY_API_KEY');
  static const String _geoapifyDailyLimitRaw =
      String.fromEnvironment('GEOAPIFY_DAILY_LIMIT');

  /// Tope diario local de llamadas Geoapify en prueba (default 100).
  static int get geoapifyDailyLimit {
    final n = int.tryParse(_geoapifyDailyLimitRaw.trim());
    if (n == null || n < 1) return 100;
    return n;
  }

  static bool get hasSupabaseConfig =>
      supabaseUrl.trim().isNotEmpty && supabaseAnonKey.trim().isNotEmpty;

  static bool get hasGoogleWebClientId => googleWebClientId.trim().isNotEmpty;

  static bool get hasGeoapifyKey => geoapifyApiKey.trim().isNotEmpty;

  /// Falla en debug si alguien intenta inyectar la service role en el cliente.
  static void assertNoServerSecrets() {
    assert(() {
      const serviceRole = String.fromEnvironment('SUPABASE_SERVICE_ROLE_KEY');
      const serviceRoleAlt = String.fromEnvironment('SUPABASE_SERVICE_ROLE');
      assert(
        serviceRole.isEmpty && serviceRoleAlt.isEmpty,
        'Nunca pases SUPABASE_SERVICE_ROLE(_KEY) al cliente. '
        'Solo anon/publishable + RLS en backend.',
      );
      assert(
        !supabaseAnonKey.contains('service_role'),
        'SUPABASE_ANON_KEY parece una service role. Usa la anon/publishable.',
      );
      return true;
    }());
  }

  /// Mensaje de bootstrap sin revelar nombres de secretos internos.
  static String get missingConfigUserMessage {
    if (kReleaseMode) {
      return 'La app no está configurada correctamente. Reinstálala o contacta soporte.';
    }
    return 'Faltan defines de build: SUPABASE_URL y SUPABASE_ANON_KEY.\n'
        'Copia .env.example → .env y usa --dart-define-from-file=.env';
  }
}
