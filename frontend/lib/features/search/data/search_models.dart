class SearchHit {
  const SearchHit({
    required this.siteId,
    required this.name,
    required this.isOwn,
    this.city,
    this.department,
    this.lat,
    this.lng,
    this.estimatedPriceAmount,
    this.currencyCode = 'COP',
    this.distanceKm,
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
  final double? distanceKm;

  factory SearchHit.fromJson(Map<String, dynamic> json) {
    final price = json['estimated_price_amount'];
    final dist = json['distance_km'];
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
      distanceKm: dist == null ? null : (dist as num).toDouble(),
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
        'distance_km': distanceKm,
      };
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
      ].join('|');
}
