import 'package:chevere_plan/features/plans/data/plan_models.dart';
import 'package:flutter_test/flutter_test.dart';

PlanStop _s(int i) => PlanStop(
      id: 'st$i',
      planId: 'p',
      siteId: 'site$i',
      sortOrder: i,
      siteName: 'S$i',
    );

void main() {
  test('reordena 2+ paradas y reescribe sortOrder', () {
    final next = Plan.reorderedStops(
      stops: [_s(0), _s(1), _s(2)],
      oldIndex: 0,
      newIndex: 2,
    );
    expect(next.map((e) => e.id), ['st1', 'st2', 'st0']);
    expect(next.map((e) => e.sortOrder), [0, 1, 2]);
  });

  test('1 parada: índices inválidos no cambian', () {
    final one = [_s(0)];
    final next = Plan.reorderedStops(
      stops: one,
      oldIndex: 0,
      newIndex: 1,
    );
    expect(identical(next, one), isTrue);
  });
}
