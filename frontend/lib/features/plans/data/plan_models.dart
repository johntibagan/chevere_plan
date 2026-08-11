class PlanStop {
  const PlanStop({
    required this.id,
    required this.planId,
    required this.siteId,
    required this.sortOrder,
    required this.siteName,
    this.lat,
    this.lng,
    this.city,
    this.visitedAt,
    this.estimatedPriceAmount,
    this.siteEstimatedPriceAmount,
  });

  final String id;
  final String planId;
  final String siteId;
  final int sortOrder;
  final String siteName;
  final double? lat;
  final double? lng;
  final String? city;
  final DateTime? visitedAt;
  final double? estimatedPriceAmount;
  final double? siteEstimatedPriceAmount;

  bool get isVisited => visitedAt != null;

  double? get displayPrice =>
      estimatedPriceAmount ?? siteEstimatedPriceAmount;

  PlanStop copyWith({
    int? sortOrder,
    DateTime? visitedAt,
    bool clearVisited = false,
    double? estimatedPriceAmount,
  }) {
    return PlanStop(
      id: id,
      planId: planId,
      siteId: siteId,
      sortOrder: sortOrder ?? this.sortOrder,
      siteName: siteName,
      lat: lat,
      lng: lng,
      city: city,
      visitedAt: clearVisited ? null : (visitedAt ?? this.visitedAt),
      estimatedPriceAmount:
          estimatedPriceAmount ?? this.estimatedPriceAmount,
      siteEstimatedPriceAmount: siteEstimatedPriceAmount,
    );
  }
}

class Plan {
  const Plan({
    required this.id,
    required this.userId,
    required this.title,
    required this.locationQuery,
    required this.includePublic,
    required this.status,
    required this.stops,
    this.startLat,
    this.startLng,
    this.maxBudgetAmount,
    this.currencyCode = 'COP',
    this.listedStopCount,
  });

  final String id;
  final String userId;
  final String title;
  final String locationQuery;
  final double? startLat;
  final double? startLng;
  final bool includePublic;
  final double? maxBudgetAmount;
  final String currencyCode;
  final String status;
  final List<PlanStop> stops;
  /// Cuando el listado usa `plan_stops(count)` en vez de stops hidratados.
  final int? listedStopCount;

  int get stopCount => listedStopCount ?? stops.length;

  List<PlanStop> get pendingStops =>
      stops.where((s) => !s.isVisited).toList();

  Map<String, dynamic> toCacheJson() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'location_query': locationQuery,
        'start_lat': startLat,
        'start_lng': startLng,
        'include_public': includePublic,
        'max_budget_amount': maxBudgetAmount,
        'currency_code': currencyCode,
        'status': status,
        'listed_stop_count': listedStopCount ?? stops.length,
      };

  factory Plan.fromCacheJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String? ?? 'Plan',
      locationQuery: json['location_query'] as String? ?? '',
      startLat: (json['start_lat'] as num?)?.toDouble(),
      startLng: (json['start_lng'] as num?)?.toDouble(),
      includePublic: json['include_public'] as bool? ?? false,
      maxBudgetAmount: (json['max_budget_amount'] as num?)?.toDouble(),
      currencyCode: json['currency_code'] as String? ?? 'COP',
      status: json['status'] as String? ?? 'active',
      stops: const [],
      listedStopCount: (json['listed_stop_count'] as num?)?.toInt() ?? 0,
    );
  }
}
