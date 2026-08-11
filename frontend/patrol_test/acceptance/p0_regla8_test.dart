import 'package:chevere_plan/core/errors/user_facing_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../helpers/app_harness.dart';
import '../helpers/fakes/failing_profile_repository.dart';

void main() {
  patrolTest(
    'P0 regla 8: fallo técnico solo muestra mensaje genérico',
    ($) async {
      final technical = StateError(
        'PostgrestException: relation "profiles" does not exist (42P01)',
      );

      // Con tokens e2e: valida en Home real (override del repo).
      // Sin tokens: valida el mismo contrato en device (Orchestrator borra
      // sesión entre tests; no depende de login manual previo).
      if (hasE2eSessionTokens) {
        await pumpChevereApp(
          $,
          overrides: [failingProfileRepositoryOverride()],
        );
        final restored = await restoreE2eSessionIfConfigured();
        expect(
          restored || hasLiveSupabaseSession,
          isTrue,
          reason: 'Tokens E2E presentes pero no se pudo restaurar la sesión.',
        );
        await $.pumpAndSettle();
        await $.waitUntilVisible(
          find.byKey(const Key('home_shell')),
          timeout: const Duration(seconds: 45),
        );
        await $.pumpAndSettle();
        expect(find.text(kGenericAppError), findsWidgets);
      } else {
        final msg = userFacingError(technical);
        await $.pumpWidgetAndSettle(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text(msg, key: const Key('regla8_msg')),
              ),
            ),
          ),
        );
        expect(find.byKey(const Key('regla8_msg')), findsOneWidget);
        expect(find.text(kGenericAppError), findsOneWidget);
      }

      expect(find.textContaining('Postgrest'), findsNothing);
      expect(find.textContaining('relation "profiles"'), findsNothing);
      expect(find.textContaining('42P01'), findsNothing);
    },
  );
}
