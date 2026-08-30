import 'package:chevere_plan/features/plans/data/plan_models.dart';
import 'package:chevere_plan/features/plans/presentation/plan_timeline.dart';
import 'package:flutter_test/flutter_test.dart';

PlanStop _s(int i) => PlanStop(
      id: 'st$i',
      planId: 'p',
      siteId: 'site$i',
      sortOrder: i,
      siteName: 'S$i',
    );

void main() {
  test('letras waypoint estilo Maps: A, B, … Z, AA', () {
    expect(planWaypointLetter(0), 'A');
    expect(planWaypointLetter(1), 'B');
    expect(planWaypointLetter(25), 'Z');
    expect(planWaypointLetter(26), 'AA');
  });

  test('visitadas no cuentan en A, B, C', () {
    final stops = [
      PlanStop(
        id: 'a',
        planId: 'p',
        siteId: 's1',
        sortOrder: 0,
        siteName: 'Done',
        visitedAt: DateTime.utc(2026, 1, 1),
      ),
      PlanStop(
        id: 'b',
        planId: 'p',
        siteId: 's2',
        sortOrder: 1,
        siteName: 'Next',
      ),
      PlanStop(
        id: 'c',
        planId: 'p',
        siteId: 's3',
        sortOrder: 2,
        siteName: 'After',
      ),
    ];
    expect(planPendingWaypointIndex(stops, 0), 0);
    expect(planPendingWaypointIndex(stops, 1), 0);
    expect(planPendingWaypointIndex(stops, 2), 1);
    expect(planWaypointLetter(planPendingWaypointIndex(stops, 1)), 'A');
    expect(planWaypointLetter(planPendingWaypointIndex(stops, 2)), 'B');
  });

  test('stopsStructureEqual ignora visitado', () {
    final a = PlanStop(
      id: '1',
      planId: 'p',
      siteId: 's1',
      sortOrder: 0,
      siteName: 'X',
    );
    final b = a.copyWith(visitedAt: DateTime.utc(2026, 1, 1));
    expect(Plan.stopsStructureEqual([a], [b]), isTrue);
    expect(Plan.stopsSnapshotEqual([a], [b]), isFalse);
  });

  test('pendingVisitedChanges solo paradas persistidas con diff', () {
    final a = PlanStop(
      id: '1',
      planId: 'p',
      siteId: 's1',
      sortOrder: 0,
      siteName: 'X',
    );
    final b = PlanStop(
      id: 'pending:s2',
      planId: 'p',
      siteId: 's2',
      sortOrder: 1,
      siteName: 'Y',
      visitedAt: DateTime.utc(2026, 1, 1),
    );
    final current = [
      a.copyWith(visitedAt: DateTime.utc(2026, 2, 1)),
      b,
    ];
    final changes = Plan.pendingVisitedChanges(initial: [a, b], current: current);
    expect(changes.length, 1);
    expect(changes.first.stopId, '1');
  });

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
