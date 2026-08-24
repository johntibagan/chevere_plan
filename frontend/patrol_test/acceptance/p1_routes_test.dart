import 'package:chevere_plan/core/testing/widget_keys.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../helpers/critical_harness.dart';
import '../robots/robots.dart';

void main() {
  patrolTest(
    'Rutas: no crash, stats visibles, sin admin',
    tags: ['critical', 'smoke', 'plans'],
    ($) async {
      if (!await requireSignedIn($)) return;
      final home = HomeRobot($);
      final routes = MyRoutesRobot($);
      await home.goRutas();
      expect(find.byKey(WidgetKeys.routesPage), findsOneWidget);
      routes.expectEmptyOrList();
      routes.expectNoAdmin();
    },
  );
}
