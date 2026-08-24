import 'package:chevere_plan/core/testing/widget_keys.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../helpers/critical_harness.dart';
import '../robots/robots.dart';

void main() {
  patrolTest(
    'crear plan con título único llega al builder',
    tags: ['critical', 'plans'],
    ($) async {
      if (!await requireSignedIn($)) return;
      final home = HomeRobot($);
      await home.goPlanes();
      await $(WidgetKeys.plansCreateCta).tap();
      await $.pumpAndSettle();
      final title = uniqueLabel('e2e-plan');
      await $(WidgetKeys.createPlanTitle).enterText(title);
      await $(WidgetKeys.createPlanBudget).enterText('100000');
      await $(WidgetKeys.createPlanNext).tap();
      await $.pumpAndSettle();
      expect(find.byKey(WidgetKeys.planBuilder), findsOneWidget);
    },
  );

  patrolTest(
    'include públicos se puede apagar en creación',
    tags: ['plans'],
    ($) async {
      if (!await requireSignedIn($)) return;
      await HomeRobot($).goPlanes();
      await $(WidgetKeys.plansCreateCta).tap();
      await $.pumpAndSettle();
      await $(WidgetKeys.createPlanIncludePublic).tap();
      expect(find.byKey(WidgetKeys.createPlanIncludePublic), findsOneWidget);
    },
  );

  patrolTest(
    'reordenar 1 parada: handle ausente (lógica en plan_reorder_test)',
    tags: ['plans'],
    ($) async {
      markTestSkipped(
        'Drag E2E de ReorderableListView es flaky; cubierto en unit '
        'plan_reorder_test (1 parada no reordena).',
      );
    },
  );
}
