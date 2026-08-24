import 'package:chevere_plan/features/routes/data/route_models.dart';
import 'package:chevere_plan/features/routes/domain/route_stats.dart';
import 'package:flutter_test/flutter_test.dart';

RouteHistoryEntry _e({
  required String stop,
  required String plan,
  String? city,
}) {
  return RouteHistoryEntry(
    stopId: stop,
    planId: plan,
    planTitle: 'P',
    siteId: 'site',
    siteName: 'Sitio',
    visitedAt: DateTime.utc(2026, 1, 1),
    city: city,
  );
}

void main() {
  test('vacío', () {
    final s = RouteStats.fromEntries(const []);
    expect(s.visited, 0);
    expect(s.cities, 0);
    expect(s.plans, 0);
  });

  test('varios planes y ciudades', () {
    final s = RouteStats.fromEntries([
      _e(stop: '1', plan: 'p1', city: 'Bogotá'),
      _e(stop: '2', plan: 'p1', city: 'Bogotá'),
      _e(stop: '3', plan: 'p2', city: 'Tunja'),
    ]);
    expect(s.visited, 3);
    expect(s.cities, 2);
    expect(s.plans, 2);
  });
}
