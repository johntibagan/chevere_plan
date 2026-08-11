import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../helpers/app_harness.dart';

void main() {
  patrolTest(
    'P0 smoke: la app arranca y muestra Login, Home o error de config',
    ($) async {
      await pumpChevereApp($);
      final shown = await waitForLoginHomeOrBootstrapError($);
      expect(shown, findsOneWidget);
    },
  );
}
