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
    this.sharedPeople = const [],
    this.createdByUserId,
    this.ownSave,
    this.estimatedPriceAmount,
    this.currencyCode = 'COP',
    this.distanceKm,
    this.lat,
    this.lng,
    this.googlePlaceId,
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
  final List<SitePerson> sharedPeople;
  final String? createdByUserId;
  final UserSave? ownSave;
  final double? estimatedPriceAmount;
  final String currencyCode;
  final double? distanceKm;
  final double? lat;
  final double? lng;
  final String? googlePlaceId;

  bool get isOwn => ownSave != null;

  bool isCreatorOf(String? userId) =>
      userId != null &&
      createdByUserId != null &&
      createdByUserId == userId;

  String get locationLine {
    final parts = <String>[
      if (addressLine != null && addressLine!.trim().isNotEmpty) addressLine!,
      if (city != null && city!.trim().isNotEmpty) city!,
      if (department != null && department!.trim().isNotEmpty) department!,
    ];
    return parts.join(', ');
  }

  Map<String, dynamic> toCacheJson() => {
        'site_id': siteId,
        'name': name,
        'city': city,
        'department': department,
        'address_line': addressLine,
        'category_names': categoryNames,
        'is_public': isPublic,
        'is_physical_place': isPhysicalPlace,
        'notes': notes,
        'source_url': sourceUrl,
        'also_shared_by': alsoSharedBy,
        'shared_people': sharedPeople.map((e) => e.toCacheJson()).toList(),
        'created_by_user_id': createdByUserId,
        'own_save': ownSave?.toCacheJson(),
        'estimated_price_amount': estimatedPriceAmount,
        'currency_code': currencyCode,
        'distance_km': distanceKm,
        'lat': lat,
        'lng': lng,
        'google_place_id': googlePlaceId,
      };

  factory SiteFicha.fromCacheJson(Map<String, dynamic> json) {
    final ownRaw = json['own_save'];
    final peopleRaw = json['shared_people'] as List?;
    final people = peopleRaw == null
        ? const <SitePerson>[]
        : peopleRaw
            .whereType<Map>()
            .map((e) => SitePerson.fromCacheJson(Map<String, dynamic>.from(e)))
            .where((p) => p.userId.isNotEmpty)
            .toList();
    final legacy = (json['also_shared_by'] as List?)
            ?.map((e) => '$e')
            .toList() ??
        const <String>[];
    return SiteFicha(
      siteId: json['site_id'] as String,
      name: json['name'] as String? ?? 'Sitio',
      city: json['city'] as String?,
      department: json['department'] as String?,
      addressLine: json['address_line'] as String?,
      categoryNames: (json['category_names'] as List?)
              ?.map((e) => '$e')
              .toList() ??
          const [],
      isPublic: json['is_public'] as bool? ?? false,
      isPhysicalPlace: json['is_physical_place'] as bool? ?? true,
      notes: json['notes'] as String?,
      sourceUrl: json['source_url'] as String?,
      alsoSharedBy: legacy,
      sharedPeople: people.isNotEmpty
          ? people
          : legacy
              .map((n) => SitePerson(userId: n, displayName: n))
              .toList(),
      createdByUserId: json['created_by_user_id'] as String?,
      ownSave: ownRaw is Map
          ? UserSave.fromCacheJson(Map<String, dynamic>.from(ownRaw))
          : null,
      estimatedPriceAmount:
          (json['estimated_price_amount'] as num?)?.toDouble(),
      currencyCode: json['currency_code'] as String? ?? 'COP',
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      googlePlaceId: json['google_place_id'] as String?,
    );
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
      sharedPeople: save.sharedPeople,
      createdByUserId: save.createdByUserId,
      ownSave: save,
      googlePlaceId: save.googlePlaceId,
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
    final createdBy = site['created_by'] as String?;
    final creatorProf = site['profiles'];
    final people = SitePerson.withCreator(
      createdById: createdBy,
      creatorProfile: creatorProf is Map ? creatorProf : null,
      contributors: SitePerson.parseContributorRows(
        site['site_contributors'] as List?,
      ),
    );
    return SiteFicha(
      siteId: site['id'] as String,
      name: (site['name'] as String?) ?? 'Sitio',
      city: site['city'] as String?,
      department: site['department'] as String?,
      addressLine: site['address_line'] as String?,
      categoryNames: names,
      isPublic: site['is_public'] as bool? ?? false,
      isPhysicalPlace: site['is_physical_place'] as bool? ?? true,
      alsoSharedBy: people.map((p) => p.tooltipName).toList(),
      sharedPeople: people,
      createdByUserId: createdBy,
      googlePlaceId: site['google_place_id'] as String?,
    );
  }

  SiteFicha copyWithMeta({
    double? estimatedPriceAmount,
    String? currencyCode,
    double? distanceKm,
    double? lat,
    double? lng,
    String? googlePlaceId,
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
      sharedPeople: sharedPeople,
      createdByUserId: createdByUserId,
      ownSave: ownSave,
      estimatedPriceAmount: estimatedPriceAmount ?? this.estimatedPriceAmount,
      currencyCode: currencyCode ?? this.currencyCode,
      distanceKm: distanceKm ?? this.distanceKm,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      googlePlaceId: googlePlaceId ?? this.googlePlaceId,
    );
  }
}

/// Resultado al cerrar la ficha (para refrescar listas).
enum SiteDetailOutcome { none, updated, deleted }
