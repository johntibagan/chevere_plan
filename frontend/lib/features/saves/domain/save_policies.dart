import '../data/save_models.dart';

/// Políticas de negocio de guardados (capa domain; sin UI ni Supabase).
abstract final class SavePolicies {
  static const int maxPhotosPerSite = 15;
  static const Duration draftRemindAfter = Duration(hours: 24);
  static const double duplicateSearchRadiusM = 100;

  /// Completo = ≥1 categoría + ubicación (ciudad, dirección o coords).
  static SiteStatus computeStatus({
    required List<String> categoryIds,
    required String? city,
    required String? addressLine,
    required double? latitude,
    required double? longitude,
  }) {
    final hasCategory = categoryIds.isNotEmpty;
    final hasLocation = (city != null && city.trim().isNotEmpty) ||
        (addressLine != null && addressLine.trim().isNotEmpty) ||
        (latitude != null && longitude != null);

    if (hasCategory && hasLocation) return SiteStatus.complete;
    if (!hasCategory && !hasLocation) return SiteStatus.draft;
    if (!hasLocation) return SiteStatus.pendingLocation;
    return SiteStatus.draft;
  }
}
