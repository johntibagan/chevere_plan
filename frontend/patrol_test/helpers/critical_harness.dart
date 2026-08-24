import 'package:chevere_plan/core/testing/widget_keys.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'app_harness.dart';

const e2eMapsUrl = String.fromEnvironment('E2E_MAPS_URL');
const e2eRefreshTokenB = String.fromEnvironment('E2E_SUPABASE_REFRESH_TOKEN_B');

String uniqueLabel(String prefix) =>
    '$prefix-${DateTime.now().microsecondsSinceEpoch}';

bool get hasSecondE2eUser => e2eRefreshTokenB.trim().isNotEmpty;

bool get hasMapsUrlFixture => e2eMapsUrl.trim().isNotEmpty;

/// Arranca app y exige sesión. Si no hay, skip (no falla el job de plumbing).
Future<bool> requireSignedIn(PatrolIntegrationTester $) async {
  await pumpChevereApp($);
  await restoreE2eSessionIfConfigured();
  await waitForLoginHomeOrBootstrapError($);
  if (!hasLiveSupabaseSession) {
    markTestSkipped(
      'Requiere sesión: E2E_SUPABASE_REFRESH_TOKEN o login previo en el device.',
    );
    return false;
  }
  expect(find.byKey(WidgetKeys.homeShell), findsOneWidget);
  return true;
}
