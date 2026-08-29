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
    this.department,
    this.googlePlaceId,
    this.useExactPin = false,
    this.visitedAt,
    this.estimatedPriceAmount,
    this.siteEstimatedPriceAmount,
    this.categoryNames = const [],
    this.coverStoragePath,
  });

  final String id;
  final String planId;
  final String siteId;
  final int sortOrder;
  final String siteName;
  final double? lat;
  final double? lng;
  final String? city;
  final String? department;
  final String? googlePlaceId;
  /// Si es true, Maps usa lat/lng; si no, el nombre del lugar.
  final bool useExactPin;
  final DateTime? visitedAt;
  final double? estimatedPriceAmount;
  final double? siteEstimatedPriceAmount;
  final List<String> categoryNames;
  final String? coverStoragePath;

  bool get isVisited => visitedAt != null;

  /// Parada solo en memoria hasta **Guardar** en el builder.
  static String pendingId(String siteId) => 'pending:$siteId';

  static bool isPendingId(String id) => id.startsWith('pending:');

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
      department: department,
      googlePlaceId: googlePlaceId,
      useExactPin: useExactPin,
      visitedAt: clearVisited ? null : (visitedAt ?? this.visitedAt),
      estimatedPriceAmount:
          estimatedPriceAmount ?? this.estimatedPriceAmount,
      siteEstimatedPriceAmount: siteEstimatedPriceAmount,
      categoryNames: categoryNames,
      coverStoragePath: coverStoragePath,
    );
  }
}

class Plan {
  const Plan({
    required this.id,
    required this.userId,
    required this.title,
    required this.locationQuery,
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
  final double? maxBudgetAmount;
  final String currencyCode;
  final String status;
  final List<PlanStop> stops;
  /// Cuando el listado usa `plan_stops(count)` en vez de stops hidratados.
  final int? listedStopCount;

  int get stopCount => listedStopCount ?? stops.length;

  /// Solo el creador (`user_id`) puede editar el plan (hoy; Fase 2 = reglas abierto/cerrado).
  bool isOwnedBy(String? currentUserId) {
    if (currentUserId == null || currentUserId.isEmpty) return false;
    return userId.toLowerCase() == currentUserId.toLowerCase();
  }

  List<PlanStop> get pendingStops =>
      stops.where((s) => !s.isVisited).toList();

  Plan copyWith({List<PlanStop>? stops}) {
    return Plan(
      id: id,
      userId: userId,
      title: title,
      locationQuery: locationQuery,
      status: status,
      stops: stops ?? this.stops,
      startLat: startLat,
      startLng: startLng,
      maxBudgetAmount: maxBudgetAmount,
      currencyCode: currencyCode,
      listedStopCount: listedStopCount,
    );
  }

  /// Compara paradas para detectar cambios locales (orden, altas/bajas, visitado).
  static bool stopsSnapshotEqual(
    List<PlanStop> initial,
    List<PlanStop> current,
  ) {
    if (initial.length != current.length) return false;
    for (var i = 0; i < initial.length; i++) {
      if (initial[i].siteId != current[i].siteId) return false;
      final a = initial[i].visitedAt?.toUtc().millisecondsSinceEpoch;
      final b = current[i].visitedAt?.toUtc().millisecondsSinceEpoch;
      if (a != b) return false;
    }
    return true;
  }

  /// Nuevo orden de paradas tras drag-and-drop ([ReorderableListView.onReorderItem]).
  static List<PlanStop> reorderedStops({
    required List<PlanStop> stops,
    required int oldIndex,
    required int newIndex,
  }) {
    if (oldIndex < 0 ||
        oldIndex >= stops.length ||
        newIndex < 0 ||
        newIndex >= stops.length ||
        oldIndex == newIndex) {
      return stops;
    }
    final next = List<PlanStop>.of(stops);
    final moved = next.removeAt(oldIndex);
    next.insert(newIndex, moved);
    return [
      for (var i = 0; i < next.length; i++) next[i].copyWith(sortOrder: i),
    ];
  }

  Map<String, dynamic> toCacheJson() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'location_query': locationQuery,
        'start_lat': startLat,
        'start_lng': startLng,
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
      maxBudgetAmount: (json['max_budget_amount'] as num?)?.toDouble(),
      currencyCode: json['currency_code'] as String? ?? 'COP',
      status: json['status'] as String? ?? 'active',
      stops: const [],
      listedStopCount: (json['listed_stop_count'] as num?)?.toInt() ?? 0,
    );
  }
}
