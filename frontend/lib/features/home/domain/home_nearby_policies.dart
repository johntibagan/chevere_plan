import 'dart:math' as math;

/// Celdas para «populares cerca»: no reconsultar si seguís cerca del ancla.
/// Misma idea que las geocercas de recuerdos (salís del radio → evento).
abstract final class HomeNearbyPolicies {
  /// Radio de la búsqueda pública (igual que Inicio hoy).
  static const double searchRadiusKm = 25;

  /// Si te desplazás más que esto respecto al ancla cacheado, nueva búsqueda.
  /// Alineado al tope de radio de recuerdos cercanos.
  static const int refetchAfterMeters = 2000;

  static const int take = 4;

  /// Aunque no te muevas, refrescar al menos una vez al día.
  static const Duration maxAge = Duration(hours: 24);

  static bool stillInRange({
    required double originLat,
    required double originLng,
    required double lat,
    required double lng,
  }) {
    return distanceMeters(originLat, originLng, lat, lng) <= refetchAfterMeters;
  }

  /// Reusar caché: dentro de la celda y no más vieja que [maxAge].
  static bool shouldReuse({
    required DateTime fetchedAtUtc,
    required DateTime nowUtc,
    required double originLat,
    required double originLng,
    required double lat,
    required double lng,
  }) {
    final age = nowUtc.difference(fetchedAtUtc);
    if (age > maxAge) return false;
    return stillInRange(
      originLat: originLat,
      originLng: originLng,
      lat: lat,
      lng: lng,
    );
  }

  static double distanceMeters(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const r = 6371000.0;
    final dLat = _rad(lat2 - lat1);
    final dLng = _rad(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(lat1)) *
            math.cos(_rad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return 2 * r * math.asin(math.min(1.0, math.sqrt(a)));
  }

  static double _rad(double d) => d * math.pi / 180.0;
}
