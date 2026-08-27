class SearchHit {
  const SearchHit({
    required this.siteId,
    required this.name,
    required this.isOwn,
    this.isPublic = false,
    this.isCatalog = false,
    this.isLinked = false,
    this.city,
    this.department,
    this.lat,
    this.lng,
    this.estimatedPriceAmount,
    this.currencyCode = 'COP',
    this.distanceKm,
    this.updatedAt,
    this.categoryNames = const [],
    this.coverStoragePath,
    this.isIncomplete = false,
    this.sourceNetwork,
    this.addressLine,
    this.isPhysicalPlace = true,
  });

  final String siteId;
  final String name;
  final String? city;
  final String? department;
  final double? lat;
  final double? lng;
  final double? estimatedPriceAmount;
  final String currencyCode;
  final bool isOwn;
  final bool isPublic;
  final bool isCatalog;
  /// Mi guardado apunta a un sitio público existente (anti-dupe).
  final bool isLinked;
  final double? distanceKm;
  final DateTime? updatedAt;
  final List<String> categoryNames;
  final String? coverStoragePath;
  final bool isIncomplete;
  final String? sourceNetwork;
  final String? addressLine;
  final bool isPhysicalPlace;

  factory SearchHit.fromJson(Map<String, dynamic> json) {
    final price = json['estimated_price_amount'];
    final dist = json['distance_km'];
    final updated = json['updated_at'];
    return SearchHit(
      siteId: json['site_id'] as String,
      name: (json['name'] as String?) ?? 'Sitio',
      city: json['city'] as String?,
      department: json['department'] as String?,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      estimatedPriceAmount:
          price == null ? null : (price as num).toDouble(),
      currencyCode: (json['currency_code'] as String?) ?? 'COP',
      isOwn: json['is_own'] as bool? ?? false,
      isPublic: json['is_public'] as bool? ?? false,
      isCatalog: json['is_catalog'] as bool? ?? false,
      isLinked: json['is_linked'] as bool? ?? false,
      distanceKm: dist == null ? null : (dist as num).toDouble(),
      updatedAt: updated is String ? DateTime.tryParse(updated) : null,
      categoryNames: (json['category_names'] as List?)
              ?.map((e) => '$e')
              .where((e) => e.isNotEmpty)
              .toList() ??
          const [],
      coverStoragePath: json['cover_storage_path'] as String?,
      isIncomplete: json['is_incomplete'] as bool? ?? false,
      sourceNetwork: json['source_network'] as String?,
      addressLine: json['address_line'] as String?,
      isPhysicalPlace: json['is_physical_place'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'site_id': siteId,
        'name': name,
        'city': city,
        'department': department,
        'lat': lat,
        'lng': lng,
        'estimated_price_amount': estimatedPriceAmount,
        'currency_code': currencyCode,
        'is_own': isOwn,
        'is_public': isPublic,
        'is_catalog': isCatalog,
        'is_linked': isLinked,
        'distance_km': distanceKm,
        'updated_at': updatedAt?.toIso8601String(),
        'category_names': categoryNames,
        'cover_storage_path': coverStoragePath,
        'is_incomplete': isIncomplete,
        'source_network': sourceNetwork,
        'address_line': addressLine,
        'is_physical_place': isPhysicalPlace,
      };

  SearchHit copyWith({
    String? siteId,
    String? name,
    String? city,
    String? department,
    double? lat,
    double? lng,
    double? estimatedPriceAmount,
    String? currencyCode,
    bool? isOwn,
    bool? isPublic,
    bool? isCatalog,
    bool? isLinked,
    double? distanceKm,
    DateTime? updatedAt,
    List<String>? categoryNames,
    String? coverStoragePath,
    bool? isIncomplete,
    String? sourceNetwork,
    String? addressLine,
    bool? isPhysicalPlace,
  }) {
    return SearchHit(
      siteId: siteId ?? this.siteId,
      name: name ?? this.name,
      city: city ?? this.city,
      department: department ?? this.department,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      estimatedPriceAmount: estimatedPriceAmount ?? this.estimatedPriceAmount,
      currencyCode: currencyCode ?? this.currencyCode,
      isOwn: isOwn ?? this.isOwn,
      isPublic: isPublic ?? this.isPublic,
      isCatalog: isCatalog ?? this.isCatalog,
      isLinked: isLinked ?? this.isLinked,
      distanceKm: distanceKm ?? this.distanceKm,
      updatedAt: updatedAt ?? this.updatedAt,
      categoryNames: categoryNames ?? this.categoryNames,
      coverStoragePath: coverStoragePath ?? this.coverStoragePath,
      isIncomplete: isIncomplete ?? this.isIncomplete,
      sourceNetwork: sourceNetwork ?? this.sourceNetwork,
      addressLine: addressLine ?? this.addressLine,
      isPhysicalPlace: isPhysicalPlace ?? this.isPhysicalPlace,
    );
  }
}

class SearchFilters {
  const SearchFilters({
    this.query,
    this.categoryId,
    this.categoryIds,
    this.locationQuery,
    this.lat,
    this.lng,
    this.radiusKm,
    this.transportGroup,
    this.budgetMin,
    this.budgetMax,
    this.includePublic = false,
    this.favoritesOnly = false,
  });

  final String? query;
  /// Compat (Planes): una sola categoría. Preferir [categoryIds].
  final String? categoryId;
  /// Padres (o hijos) seleccionados; vacío/null = sin filtro de categoría.
  final List<String>? categoryIds;
  final String? locationQuery;
  final double? lat;
  final double? lng;
  final double? radiusKm;
  final String? transportGroup; // particular | publico | otro (oculto en UI Explorar)
  final double? budgetMin;
  final double? budgetMax;
  final bool includePublic;
  /// Solo sitios en `site_favorites` del usuario.
  final bool favoritesOnly;

  /// IDs efectivos para el RPC (multi + legacy).
  List<String> get effectiveCategoryIds {
    final multi = categoryIds
            ?.map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList() ??
        const <String>[];
    if (multi.isNotEmpty) return multi;
    final one = categoryId?.trim();
    if (one != null && one.isNotEmpty) return [one];
    return const [];
  }

  /// Params PostgREST; extensible: sumar claves aquí al agregar filtros.
  Map<String, dynamic> toRpcParams() {
    final params = <String, dynamic>{
      'p_include_public': includePublic,
      'p_favorites_only': favoritesOnly,
    };
    final q = query?.trim();
    if (q != null && q.isNotEmpty) params['p_query'] = q;

    final cats = effectiveCategoryIds;
    if (cats.length == 1) {
      params['p_category_id'] = cats.first;
    } else if (cats.length > 1) {
      params['p_category_ids'] = cats;
    }

    final loc = locationQuery?.trim();
    if (loc != null && loc.isNotEmpty) params['p_location_query'] = loc;
    if (lat != null) params['p_lat'] = lat;
    if (lng != null) params['p_lng'] = lng;
    if (radiusKm != null) params['p_radius_km'] = radiusKm;
    if (transportGroup != null && transportGroup!.isNotEmpty) {
      params['p_transport_group'] = transportGroup;
    }
    if (budgetMin != null) params['p_budget_min'] = budgetMin;
    if (budgetMax != null) params['p_budget_max'] = budgetMax;
    return params;
  }

  String get cacheKey => [
        query ?? '',
        effectiveCategoryIds.join(','),
        locationQuery ?? '',
        lat?.toStringAsFixed(4) ?? '',
        lng?.toStringAsFixed(4) ?? '',
        radiusKm?.toString() ?? '',
        transportGroup ?? '',
        budgetMin?.toString() ?? '',
        budgetMax?.toString() ?? '',
        includePublic ? '1' : '0',
        favoritesOnly ? 'fav1' : 'fav0',
        'v8', // favoritos
      ].join('|');
}

