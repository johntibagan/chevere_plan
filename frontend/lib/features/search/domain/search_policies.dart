/// Políticas de Explorar (paginación y radio en km).
///
/// El radio de **recuerdos cercanos** se guarda en metros (`ProximityPolicies`).
/// La UI muestra distancias en la unidad preferida del usuario
/// (`preferredDistanceUnitProvider` / catálogo `distance_units`).
abstract final class SearchPolicies {
  /// Página del RPC `search_sites` (`p_limit` / `p_offset`).
  static const int pageSize = 15;

  static const double minRadiusKm = 0.5;
  static const double maxRadiusKm = 50;
  static const double radiusStepKm = 0.5;

  /// Debounce del texto libre (ms).
  static const int queryDebounceMs = 450;

  static double clampRadiusKm(double value) {
    if (value < minRadiusKm) return minRadiusKm;
    if (value > maxRadiusKm) return maxRadiusKm;
    final steps = (value / radiusStepKm).round();
    return (steps * radiusStepKm).clamp(minRadiusKm, maxRadiusKm);
  }

  /// Preferencia de recuerdos (m) → km redondeado al paso de Explorar.
  static double kmFromProximityMeters(int meters) {
    return clampRadiusKm(meters / 1000.0);
  }
}
