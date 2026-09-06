class RouteHistoryEntry {
  const RouteHistoryEntry({
    required this.stopId,
    required this.planId,
    required this.planTitle,
    required this.siteId,
    required this.siteName,
    required this.visitedAt,
    this.city,
    this.coverStoragePath,
    this.categoryNames = const [],
  });

  final String stopId;
  final String planId;
  final String planTitle;
  final String siteId;
  final String siteName;
  final String? city;
  final DateTime visitedAt;
  final String? coverStoragePath;
  final List<String> categoryNames;

  RouteHistoryEntry copyWith({
    String? coverStoragePath,
    List<String>? categoryNames,
  }) {
    return RouteHistoryEntry(
      stopId: stopId,
      planId: planId,
      planTitle: planTitle,
      siteId: siteId,
      siteName: siteName,
      visitedAt: visitedAt,
      city: city,
      coverStoragePath: coverStoragePath ?? this.coverStoragePath,
      categoryNames: categoryNames ?? this.categoryNames,
    );
  }

  factory RouteHistoryEntry.fromJson(Map<String, dynamic> json) {
    final cats = json['category_names'];
    return RouteHistoryEntry(
      stopId: json['stop_id'] as String,
      planId: json['plan_id'] as String,
      planTitle: (json['plan_title'] as String?) ?? 'Plan',
      siteId: json['site_id'] as String,
      siteName: (json['site_name'] as String?) ?? 'Sitio',
      city: json['city'] as String?,
      visitedAt: DateTime.parse(json['visited_at'] as String),
      coverStoragePath: json['cover_storage_path'] as String?,
      categoryNames: cats is List
          ? cats.map((e) => '$e').where((e) => e.isNotEmpty).toList()
          : const [],
    );
  }

  Map<String, dynamic> toCacheJson() => {
        'stop_id': stopId,
        'plan_id': planId,
        'plan_title': planTitle,
        'site_id': siteId,
        'site_name': siteName,
        'city': city,
        'visited_at': visitedAt.toUtc().toIso8601String(),
        'cover_storage_path': coverStoragePath,
        'category_names': categoryNames,
      };

  factory RouteHistoryEntry.fromCacheJson(Map<String, dynamic> json) {
    return RouteHistoryEntry.fromJson(json);
  }
}
