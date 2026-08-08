import '../../admin/data/admin_models.dart';

/// Sugiere medios de transporte según distancia (§7.2).
class TransportSuggester {
  const TransportSuggester({
    required this.types,
    this.userMaxKmBySlug = const {},
  });

  final List<TransportType> types;
  final Map<String, double> userMaxKmBySlug;

  /// Todos los medios cuyo tope es null o >= [distanceKm].
  List<TransportType> suggestForDistanceKm(double distanceKm) {
    final active = types.where((t) => t.isActive).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return active.where((t) {
      final override = userMaxKmBySlug[t.slug];
      final maxKm = override ?? t.defaultMaxKm;
      if (maxKm == null) return true;
      return distanceKm <= maxKm;
    }).toList();
  }
}
