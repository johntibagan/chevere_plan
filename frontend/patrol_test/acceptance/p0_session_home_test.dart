import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../helpers/app_harness.dart';

void main() {
  patrolTest(
    'P0 sesión: con tokens e2e o sesión persistida llega a Home; si no, Login',
    ($) async {
      await pumpChevereApp($);

      final restored = await restoreE2eSessionIfConfigured();
      if (restored) {
        await $.pumpAndSettle();
      }

      final shown = await waitForLoginHomeOrBootstrapError($);

      if (hasE2eSessionTokens || hasLiveSupabaseSession || restored) {
        expect(
          find.byKey(const Key('home_shell')),
          findsOneWidget,
          reason:
              'Con tokens E2E o sesión en dispositivo debe verse Home. '
              'Si falla: renueva refresh token o haz login manual una vez.',
        );
      } else {
        expect(
          find.byKey(const Key('login_google_button')),
          findsOneWidget,
          reason:
              'Sin sesión: se espera Login. P0 no automatiza el picker de Google.',
        );
        expect(shown, findsOneWidget);
      }
    },
  );
}
