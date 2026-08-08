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

  List<PlanStop> get pendingStops =>
      stops.where((s) => !s.isVisited).toList();
}
