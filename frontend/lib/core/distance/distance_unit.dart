/// Unidad de distancia del catálogo (admin). Canon de conversión: metros.
class DistanceUnit {
  const DistanceUnit({
    required this.id,
    required this.slug,
    required this.nameEs,
    required this.symbol,
    required this.metersPerUnit,
    required this.isActive,
    required this.isDefault,
    required this.sortOrder,
  });

  final String id;
  final String slug;
  final String nameEs;
  final String symbol;
  final double metersPerUnit;
  final bool isActive;
  final bool isDefault;
  final int sortOrder;

  /// Fallback si el catálogo aún no cargó (km por defecto).
  static const DistanceUnit fallbackKm = DistanceUnit(
    id: 'fallback-km',
    slug: 'km',
    nameEs: 'Kilómetros',
    symbol: 'km',
    metersPerUnit: 1000,
    isActive: true,
    isDefault: true,
    sortOrder: 20,
  );

  double metersToUnit(num meters) => meters / metersPerUnit;

  double unitToMeters(num value) => value * metersPerUnit;

  double kmToUnit(num km) => metersToUnit(km * 1000.0);

  double unitToKm(num value) => unitToMeters(value) / 1000.0;

  int get displayFractionDigits => metersPerUnit <= 1.0 ? 0 : 1;

  Map<String, dynamic> toCacheJson() => {
        'id': id,
        'slug': slug,
        'name_i18n': {'es': nameEs},
        'symbol': symbol,
        'meters_per_unit': metersPerUnit,
        'is_active': isActive,
        'is_default': isDefault,
        'sort_order': sortOrder,
      };

  factory DistanceUnit.fromJson(Map<String, dynamic> json) {
    final nameI18n = json['name_i18n'];
    String nameEs = json['slug'] as String? ?? '';
    if (nameI18n is Map) {
      nameEs = (nameI18n['es'] as String?) ?? nameEs;
    }
    return DistanceUnit(
      id: json['id'] as String,
      slug: json['slug'] as String,
      nameEs: nameEs,
      symbol: (json['symbol'] as String?)?.trim().isNotEmpty == true
          ? (json['symbol'] as String).trim()
          : (json['slug'] as String? ?? 'km'),
      metersPerUnit: (json['meters_per_unit'] as num?)?.toDouble() ?? 1000,
      isActive: json['is_active'] as bool? ?? true,
      isDefault: json['is_default'] as bool? ?? false,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  /// Elige unidad activa por slug; si no, la default; si no, [fallbackKm].
  static DistanceUnit resolve(
    List<DistanceUnit> units, {
    String? preferredSlug,
  }) {
    final active = units.where((u) => u.isActive).toList();
    if (active.isEmpty) return fallbackKm;
    if (preferredSlug != null && preferredSlug.isNotEmpty) {
      for (final u in active) {
        if (u.slug == preferredSlug) return u;
      }
    }
    for (final u in active) {
      if (u.isDefault) return u;
    }
    return active.first;
  }
}
