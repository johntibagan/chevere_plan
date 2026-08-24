import '../data/route_models.dart';

class RouteStats {
  const RouteStats({
    required this.visited,
    required this.cities,
    required this.plans,
  });

  final int visited;
  final int cities;
  final int plans;

  factory RouteStats.fromEntries(Iterable<RouteHistoryEntry> all) {
    final list = all.toList();
    final cities = list
        .map((e) => e.city?.trim() ?? '')
        .where((c) => c.isNotEmpty)
        .toSet()
        .length;
    final plans = list.map((e) => e.planId).toSet().length;
    return RouteStats(
      visited: list.length,
      cities: cities,
      plans: plans,
    );
  }
}
