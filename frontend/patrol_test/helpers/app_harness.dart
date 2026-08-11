import 'package:chevere_plan/bootstrap.dart';
import 'package:chevere_plan/core/config/env.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Tokens opcionales para restaurar sesión sin UI de Google
/// (`E2E_SUPABASE_ACCESS_TOKEN` + `E2E_SUPABASE_REFRESH_TOKEN`).
const e2eAccessToken = String.fromEnvironment('E2E_SUPABASE_ACCESS_TOKEN');
const e2eRefreshToken = String.fromEnvironment('E2E_SUPABASE_REFRESH_TOKEN');

bool get hasE2eSessionTokens =>
    e2eAccessToken.trim().isNotEmpty && e2eRefreshToken.trim().isNotEmpty;

/// Arranca la app real (Firebase + Supabase e2e) con overrides opcionales.
Future<void> pumpChevereApp(
  PatrolIntegrationTester $, {
  List<Override> overrides = const [],
  bool initFirebase = true,
  bool initLocalNotifications = true,
}) async {
  final app = await createRootApp(
    initFirebase: initFirebase,
    initLocalNotifications: initLocalNotifications,
    overrides: overrides,
  );
  await $.pumpWidgetAndSettle(app);
}

/// Restaura sesión Supabase si hay tokens e2e (evita Google Account Picker).
Future<bool> restoreE2eSessionIfConfigured() async {
  if (!hasE2eSessionTokens) return false;
  if (!Env.hasSupabaseConfig) return false;

  final res = await Supabase.instance.client.auth.setSession(e2eRefreshToken);
  return res.session != null;
}

/// true si hay sesión Supabase viva.
bool get hasLiveSupabaseSession =>
    Supabase.instance.client.auth.currentSession != null;

/// Espera Login, Home o error de bootstrap (smoke).
Future<Finder> waitForLoginHomeOrBootstrapError(
  PatrolIntegrationTester $, {
  Duration timeout = const Duration(seconds: 45),
}) async {
  final login = find.byKey(const Key('login_google_button'));
  final home = find.byKey(const Key('home_shell'));
  final bootErr = find.byKey(const Key('bootstrap_error'));
  final deadline = DateTime.now().add(timeout);

  while (DateTime.now().isBefore(deadline)) {
    await $.pump(const Duration(milliseconds: 250));
    if (login.evaluate().isNotEmpty) return login;
    if (home.evaluate().isNotEmpty) return home;
    if (bootErr.evaluate().isNotEmpty) return bootErr;
  }

  fail(
    'Timeout: no apareció login_google_button, home_shell ni bootstrap_error',
  );
}
