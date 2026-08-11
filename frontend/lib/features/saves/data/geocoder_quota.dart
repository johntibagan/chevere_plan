import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/env.dart';

/// Cupo diario local para no pasarnos del free tier de Geoapify en prueba.
class GeocoderQuota {
  GeocoderQuota({int? dailyLimit})
      : dailyLimit = dailyLimit ?? Env.geoapifyDailyLimit;

  final int dailyLimit;

  static String _dayKey() {
    final now = DateTime.now().toUtc();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return 'geoapify_quota_$y$m$d';
  }

  Future<int> usedToday() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_dayKey()) ?? 0;
  }

  Future<int> remainingToday() async {
    final used = await usedToday();
    final left = dailyLimit - used;
    return left < 0 ? 0 : left;
  }

  /// Consume 1 crédito si hay cupo. Devuelve false si ya se agotó.
  Future<bool> tryConsume() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _dayKey();
    final used = prefs.getInt(key) ?? 0;
    if (used >= dailyLimit) return false;
    await prefs.setInt(key, used + 1);
    return true;
  }
}
