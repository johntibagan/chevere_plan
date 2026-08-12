import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Tope: 1 recuerdo local por sitio y día civil (hora local del dispositivo).
class ProximityNotifyThrottle {
  ProximityNotifyThrottle._();

  static const _kLastShownMap = 'proximity_last_shown_v1';

  /// Día local `yyyy-MM-dd`.
  static String dayKey([DateTime? now]) {
    final n = now ?? DateTime.now();
    final y = n.year.toString().padLeft(4, '0');
    final m = n.month.toString().padLeft(2, '0');
    final d = n.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static Future<bool> shouldNotify(String siteId, {DateTime? now}) async {
    final id = siteId.trim();
    if (id.isEmpty) return false;
    final prefs = await SharedPreferences.getInstance();
    final map = _readMap(prefs);
    return map[id] != dayKey(now);
  }

  static Future<void> markShown(String siteId, {DateTime? now}) async {
    final id = siteId.trim();
    if (id.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final map = _readMap(prefs);
    map[id] = dayKey(now);
    await prefs.setString(_kLastShownMap, jsonEncode(map));
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kLastShownMap);
  }

  static Map<String, String> _readMap(SharedPreferences prefs) {
    final raw = prefs.getString(_kLastShownMap);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return {};
      return {
        for (final e in decoded.entries)
          if (e.key is String && e.value is String)
            e.key as String: e.value as String,
      };
    } catch (_) {
      return {};
    }
  }
}
