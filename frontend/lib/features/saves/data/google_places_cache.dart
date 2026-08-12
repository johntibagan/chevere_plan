import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'geo_place.dart';

/// Caché simple de Place Details / reverse (TTL 14 días).
class GooglePlacesCache {
  static const _prefix = 'gplaces_cache_v1_';
  static const _ttl = Duration(days: 14);

  Future<GeoPlace?> read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefix${_safe(key)}');
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final at = DateTime.tryParse(map['at'] as String? ?? '');
      if (at == null || DateTime.now().toUtc().difference(at) > _ttl) {
        await prefs.remove('$_prefix${_safe(key)}');
        return null;
      }
      final p = map['place'];
      if (p is! Map) return null;
      return GeoPlace.fromJson(Map<String, dynamic>.from(p));
    } catch (_) {
      return null;
    }
  }

  Future<void> write(String key, GeoPlace place) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_prefix${_safe(key)}',
      jsonEncode({
        'at': DateTime.now().toUtc().toIso8601String(),
        'place': place.toJson(),
      }),
    );
  }

  static String _safe(String key) =>
      key.replaceAll(RegExp(r'[^a-zA-Z0-9_.:-]'), '_');
}
