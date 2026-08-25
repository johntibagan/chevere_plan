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
    );
  }
}

class SearchFilters {
  const SearchFilters({
    this.query,
    this.categoryId,
    this.locationQuery,
    this.lat,
    this.lng,
    this.radiusKm,
    this.transportGroup,
    this.budgetMin,
    this.budgetMax,
    this.includePublic = false,
  });

  final String? query;
  final String? categoryId;
  final String? locationQuery;
  final double? lat;
  final double? lng;
  final double? radiusKm;
  final String? transportGroup; // particular | publico | otro
  final double? budgetMin;
  final double? budgetMax;
  final bool includePublic;

  String get cacheKey => [
        query ?? '',
        categoryId ?? '',
        locationQuery ?? '',
        lat?.toStringAsFixed(4) ?? '',
        lng?.toStringAsFixed(4) ?? '',
        radiusKm?.toString() ?? '',
        transportGroup ?? '',
        budgetMin?.toString() ?? '',
        budgetMax?.toString() ?? '',
        includePublic ? '1' : '0',
        'v6', // portada cover_photo_id
      ].join('|');
}
