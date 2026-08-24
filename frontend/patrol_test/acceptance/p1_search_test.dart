import 'package:chevere_plan/core/testing/widget_keys.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../helpers/critical_harness.dart';
import '../robots/robots.dart';

void main() {
  patrolTest(
    'Explorar: query + incluir públicos (toggle por key)',
    tags: ['critical', 'saves'],
    ($) async {
      if (!await requireSignedIn($)) return;
      final home = HomeRobot($);
      final search = SearchRobot($);
      await home.goExplorar();
      await search.setIncludePublic(true);
      await search.search('parque');
      expect(find.byKey(WidgetKeys.searchQuery), findsOneWidget);
    },
  );
}
