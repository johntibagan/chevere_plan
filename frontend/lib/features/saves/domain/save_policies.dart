import '../data/save_models.dart';

/// Políticas de negocio de guardados (capa domain; sin UI ni Supabase).
abstract final class SavePolicies {
  static const int maxPhotosPerSite = 15;
  static const Duration draftRemindAfter = Duration(hours: 24);

  /// Radio por defecto para detectar el mismo sitio por pin (m).
  static const int defaultDuplicateSearchRadiusM = 100;
  static const int minDuplicateSearchRadiusM = 50;
  static const int maxDuplicateSearchRadiusM = 1000;

  static int clampDuplicateSearchRadiusM(int meters) {
    if (meters < minDuplicateSearchRadiusM) return minDuplicateSearchRadiusM;
    if (meters > maxDuplicateSearchRadiusM) return maxDuplicateSearchRadiusM;
    return meters;
  }

  /// Recordatorios locales espaciados hasta completar o descartar (§3.1).
  static const List<Duration> draftRemindDelays = [
    Duration(hours: 24),
    Duration(days: 3),
    Duration(days: 7),
  ];

  /// Coordenadas GPS guardadas (punto en mapa). Imprescindibles para Maps y planes.
  static bool hasCoordinates({
    required double? latitude,
    required double? longitude,
  }) {
    return latitude != null && longitude != null;
  }

  /// Ubicación usable: lat/lng. Ciudad o dirección solas no bastan para Maps.
  static bool hasLocation({
    required String? city,
    required String? addressLine,
    required double? latitude,
    required double? longitude,
  }) {
    return hasCoordinates(latitude: latitude, longitude: longitude);
  }

  /// Completo = ≥1 categoría + coords (lugar físico) o solo categoría (no físico).
  /// Sin coords en lugar físico: si eligió categoría → `pending_location`;
  /// si no (share rápido / solo default) → `draft`.
  static SiteStatus computeStatus({
    required List<String> categoryIds,
    required String? city,
    required String? addressLine,
    required double? latitude,
    required double? longitude,
    bool categoryIsExplicit = true,
    bool isPhysicalPlace = true,
  }) {
    final hasAnyCategory = categoryIds.isNotEmpty;
    final hasExplicitCategory = hasAnyCategory && categoryIsExplicit;
    final located = !isPhysicalPlace ||
        hasCoordinates(latitude: latitude, longitude: longitude);

    if (hasAnyCategory && located) return SiteStatus.complete;
    if (!located && hasExplicitCategory) return SiteStatus.pendingLocation;
    if (!located) return SiteStatus.draft;
    return SiteStatus.draft;
  }
}
