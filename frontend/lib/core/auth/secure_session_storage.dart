import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../logging/app_log.dart';

/// Sesión JWT en Keystore (Android EncryptedSharedPreferences), no en prefs plano.
///
/// Migra una vez la clave que usa supabase_flutter por defecto
/// (`sb-<project-ref>-auth-token`). El verifier PKCE sigue en SharedPreferences
/// (vida corta; lo gestiona el SDK).
class SecureSessionStorage extends LocalStorage {
  SecureSessionStorage({required String supabaseUrl})
      : persistSessionKey = _keyForUrl(supabaseUrl);

  final String persistSessionKey;

  static const _android = AndroidOptions();

  final FlutterSecureStorage _secure = const FlutterSecureStorage(
    aOptions: _android,
  );

  static String _keyForUrl(String url) {
    final host = Uri.tryParse(url)?.host ?? '';
    final ref = host.split('.').first;
    return 'sb-$ref-auth-token';
  }

  @override
  Future<void> initialize() async {
    if (kIsWeb) return;
    try {
      final existing = await _secure.read(key: persistSessionKey);
      if (existing != null && existing.isNotEmpty) return;
      final prefs = await SharedPreferences.getInstance();
      final legacy = prefs.getString(persistSessionKey);
      if (legacy != null && legacy.isNotEmpty) {
        await _secure.write(key: persistSessionKey, value: legacy);
        await prefs.remove(persistSessionKey);
      }
    } catch (_) {
      // Si el Keystore no está listo, supabase fallará al persistir; no filtrar.
    }
  }

  /// Lee y parsea la sesión persistida en este dispositivo (sin red).
  ///
  /// Solo sirve para pintar UI de forma optimista en el mismo aparato que
  /// guardó el JWT en Keystore — no es sesión de otro usuario/dispositivo.
  Future<Session?> peekSession() async {
    try {
      await initialize();
      final raw = await accessToken();
      return parsePersistedSession(raw);
    } catch (e, st) {
      AppLog.debug(
        'peekSession',
        name: 'auth',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  /// Parsea el JSON que supabase_flutter guarda (`jsonEncode(session.toJson())`).
  static Session? parsePersistedSession(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return Session.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> hasAccessToken() async {
    final v = await accessToken();
    return v != null && v.isNotEmpty;
  }

  @override
  Future<String?> accessToken() => _secure.read(key: persistSessionKey);

  @override
  Future<void> removePersistedSession() =>
      _secure.delete(key: persistSessionKey);

  @override
  Future<void> persistSession(String persistSessionString) =>
      _secure.write(key: persistSessionKey, value: persistSessionString);
}
