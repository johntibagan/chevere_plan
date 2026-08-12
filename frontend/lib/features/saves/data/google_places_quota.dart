import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/env.dart';

/// Cupo diario local para Places + Geocoding (anti-fugas de factura).
class GooglePlacesQuota {
  GooglePlacesQuota({int? dailyLimit})
      : dailyLimit = dailyLimit ?? Env.googlePlacesDailyLimit;

  final int dailyLimit;

  static String _dayKey() {
    final now = DateTime.now().toUtc();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return 'google_places_quota_$y$m$d';
  }

  Future<int> usedToday() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_dayKey()) ?? 0;
  }

  Future<bool> tryConsume() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _dayKey();
    final used = prefs.getInt(key) ?? 0;
    if (used >= dailyLimit) return false;
    await prefs.setInt(key, used + 1);
    return true;
  }
}
