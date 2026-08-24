import '../../search/data/search_models.dart';

class HomeNearbySnapshot {
  const HomeNearbySnapshot({
    required this.hits,
    this.originLat,
    this.originLng,
    this.needGps = false,
  });

  final List<SearchHit> hits;
  final double? originLat;
  final double? originLng;
  final bool needGps;

  Map<String, dynamic> toCacheJson() => {
        'lat': originLat,
        'lng': originLng,
        'hits': hits.map((h) => h.toJson()).toList(),
      };

  static HomeNearbySnapshot? fromCachePayload(Object? payload) {
    if (payload is! Map) return null;
    final map = Map<String, dynamic>.from(payload);
    final rawHits = map['hits'];
    if (rawHits is! List) return null;
    final hits = <SearchHit>[];
    for (final row in rawHits) {
      if (row is! Map) continue;
      try {
        hits.add(SearchHit.fromJson(Map<String, dynamic>.from(row)));
      } catch (_) {}
    }
    return HomeNearbySnapshot(
      hits: hits,
      originLat: (map['lat'] as num?)?.toDouble(),
      originLng: (map['lng'] as num?)?.toDouble(),
    );
  }
}
