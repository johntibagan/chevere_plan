import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/env.dart';
import '../../../core/formatters/date_format.dart';

/// Cupo diario local para Places + Geocoding (anti-fugas de factura).
class GooglePlacesQuota {
  GooglePlacesQuota({int? dailyLimit})
      : dailyLimit = dailyLimit ?? Env.googlePlacesDailyLimit;

  final int dailyLimit;

  static String _dayKey() =>
      'google_places_quota_${formatUtcDayCompact()}';

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
