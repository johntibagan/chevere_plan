import 'package:geolocator/geolocator.dart';

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
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
  }
}
