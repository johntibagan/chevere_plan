import 'package:chevere_plan/core/config/env.dart';
import 'package:chevere_plan/core/errors/user_facing_error.dart';
import 'package:chevere_plan/core/logging/app_log.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('userFacingError oculta errores técnicos', () {
    expect(userFacingError(StateError('secret detail')), kGenericAppError);
    expect(
      userFacingError(const AppUserError('Falta categoría')),
      'Falta categoría',
    );
  });

  test('AppLog.redact oculta JWT y apiKey en query', () {
    const jwt = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.aaa.bbb';
    expect(AppLog.redact('token=$jwt'), isNot(contains('eyJhbGciOi')));
    expect(
      AppLog.redact('https://x.test/v1?apiKey=supersecret&x=1'),
      contains('apiKey=[redacted]'),
    );
    expect(
      AppLog.redact('Authorization: Bearer abc.def.ghi'),
      contains('[redacted]'),
    );
  });

  test('Env no expone config sin dart-define', () {
    expect(Env.hasSupabaseConfig, isFalse);
    expect(Env.missingConfigUserMessage, isNotEmpty);
  });
}
