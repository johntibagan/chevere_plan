import 'package:chevere_plan/core/errors/result.dart';
import 'package:chevere_plan/core/errors/user_facing_error.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Ok y Err', () {
    const ok = Ok<int>(2);
    expect(ok.isOk, isTrue);
    expect(ok.valueOrNull, 2);

    final err = Err<int>(Failure.from(Exception('PGRST')));
    expect(err.isErr, isTrue);
    expect(err.failure.userMessage, kGenericAppError);
  });

  test('AppUserError conserva mensaje de negocio', () {
    final f = Failure.from(const AppUserError('Máximo 15 fotos por sitio'));
    expect(f.userMessage, 'Máximo 15 fotos por sitio');
  });
}
