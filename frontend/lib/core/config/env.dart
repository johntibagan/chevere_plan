import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Variables de entorno locales (frontend/.env). No hardcodear secretos.
class Env {
  Env._();

  static String get supabaseUrl => dotenv.env['SUPABASE_URL']?.trim() ?? '';

  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY']?.trim() ?? '';

  /// OAuth Client ID tipo **Web** en Google Cloud (necesario para idToken en Android).
  static String get googleWebClientId =>
      dotenv.env['GOOGLE_WEB_CLIENT_ID']?.trim() ?? '';

  /// Geoapify (autocomplete + reverse). Free tier sin tarjeta.
  static String get geoapifyApiKey =>
      dotenv.env['GEOAPIFY_API_KEY']?.trim() ?? '';

  /// Tope diario local de llamadas Geoapify en prueba (default 100).
  static int get geoapifyDailyLimit {
    final raw = dotenv.env['GEOAPIFY_DAILY_LIMIT']?.trim();
    final n = int.tryParse(raw ?? '');
    if (n == null || n < 1) return 100;
    return n;
  }

  static bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static bool get hasGoogleWebClientId => googleWebClientId.isNotEmpty;

  static bool get hasGeoapifyKey => geoapifyApiKey.isNotEmpty;
}
