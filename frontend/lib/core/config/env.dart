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

  static bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static bool get hasGoogleWebClientId => googleWebClientId.isNotEmpty;
}
