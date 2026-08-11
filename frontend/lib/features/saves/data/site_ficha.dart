import 'save_models.dart';
import '../../search/data/search_models.dart';

/// Vista unificada de ficha de sitio (propia o pública).
class SiteFicha {
  const SiteFicha({
    required this.siteId,
    required this.name,
    this.city,
    this.department,
    this.addressLine,
    this.categoryNames = const [],
    this.isPublic = false,
    this.isPhysicalPlace = true,
    this.notes,
    this.sourceUrl,
    this.alsoSharedBy = const [],
    this.ownSave,
    this.estimatedPriceAmount,
    this.currencyCode = 'COP',
    this.distanceKm,
    this.lat,
    this.lng,
  });

  final String siteId;
  final String name;
  final String? city;
  final String? department;
  final String? addressLine;
  final List<String> categoryNames;
  final bool isPublic;
  final bool isPhysicalPlace;
  final String? notes;
  final String? sourceUrl;
  final List<String> alsoSharedBy;
  final UserSave? ownSave;
  final double? estimatedPriceAmount;
  final String currencyCode;
  final double? distanceKm;
  final double? lat;
  final double? lng;

  bool get isOwn => ownSave != null;

  String get locationLine {
    final parts = <String>[
      if (addressLine != null && addressLine!.trim().isNotEmpty) addressLine!,
      if (city != null && city!.trim().isNotEmpty) city!,
      if (department != null && department!.trim().isNotEmpty) department!,
    ];
    return parts.join(', ');
  }

  factory SiteFicha.fromSave(UserSave save) {
    return SiteFicha(
      siteId: save.siteId,
      name: save.siteName,
      city: save.city,
      department: save.department,
      addressLine: save.addressLine,
      categoryNames: save.categoryNames,
      isPublic: save.isPublic,
      isPhysicalPlace: save.isPhysicalPlace,
      notes: save.notes,
      sourceUrl: save.sourceUrl,
      alsoSharedBy: save.alsoSharedBy,
      ownSave: save,
    );
  }

  factory SiteFicha.fromSearchHit(SearchHit hit, {UserSave? ownSave}) {
    if (ownSave != null) return SiteFicha.fromSave(ownSave);
    return SiteFicha(
      siteId: hit.siteId,
      name: hit.name,
      city: hit.city,
      department: hit.department,
      isPublic: !hit.isOwn,
      estimatedPriceAmount: hit.estimatedPriceAmount,
      currencyCode: hit.currencyCode,
      distanceKm: hit.distanceKm,
      lat: hit.lat,
      lng: hit.lng,
      ownSave: ownSave,
    );
  }

  factory SiteFicha.fromSiteRow(Map<String, dynamic> site) {
    final catsRaw = site['site_categories'] as List? ?? const [];
    final names = <String>[];
    for (final row in catsRaw) {
      if (row is! Map) continue;
      final cat = row['categories'];
      if (cat is Map) {
        final i18n = cat['name_i18n'];
        if (i18n is Map && i18n['es'] is String) {
          names.add(i18n['es'] as String);
        }
      }
    }
    final contribs = <String>[];
    final contribRaw = site['site_contributors'] as List? ?? const [];
    for (final row in contribRaw) {
      if (row is! Map) continue;
      final profile = row['profiles'];
      if (profile is Map) {
        final n = profile['display_name'] as String?;
        if (n != null && n.isNotEmpty) contribs.add(n);
      }
    }
    return SiteFicha(
      siteId: site['id'] as String,
      name: (site['name'] as String?) ?? 'Sitio',
      city: site['city'] as String?,
      department: site['department'] as String?,
      addressLine: site['address_line'] as String?,
      categoryNames: names,
      isPublic: site['is_public'] as bool? ?? false,
      isPhysicalPlace: site['is_physical_place'] as bool? ?? true,
      alsoSharedBy: contribs,
    );
  }

  SiteFicha copyWithMeta({
    double? estimatedPriceAmount,
    String? currencyCode,
    double? distanceKm,
    double? lat,
    double? lng,
  }) {
    return SiteFicha(
      siteId: siteId,
      name: name,
      city: city,
      department: department,
      addressLine: addressLine,
      categoryNames: categoryNames,
      isPublic: isPublic,
      isPhysicalPlace: isPhysicalPlace,
      notes: notes,
      sourceUrl: sourceUrl,
      alsoSharedBy: alsoSharedBy,
      ownSave: ownSave,
      estimatedPriceAmount: estimatedPriceAmount ?? this.estimatedPriceAmount,
      currencyCode: currencyCode ?? this.currencyCode,
      distanceKm: distanceKm ?? this.distanceKm,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }
}

/// Resultado al cerrar la ficha (para refrescar listas).
enum SiteDetailOutcome { none, updated, deleted }
