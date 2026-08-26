import 'package:shared_preferences/shared_preferences.dart';

import '../domain/search_policies.dart';

/// Persistencia local del radio de Explorar (km).
///
/// Independiente de `profiles.proximity_radius_m` (recuerdos cercanos).
abstract final class ExploreRadiusStore {
  static const _keyKm = 'explore_radius_km';

  /// Si ya hay valor guardado, ese; si no, [fallbackFromProximityM] convertido.
  static Future<double> resolveInitialKm({
    required int proximityRadiusM,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getDouble(_keyKm);
    if (stored != null) {
      return SearchPolicies.clampRadiusKm(stored);
    }
    return SearchPolicies.kmFromProximityMeters(proximityRadiusM);
  }

  static Future<void> saveKm(double km) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyKm, SearchPolicies.clampRadiusKm(km));
  }

  /// Reset: vuelve a heredar recuerdos la próxima vez (borra el último usado).
  static Future<void> clearStored() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyKm);
  }
}
