import 'package:flutter_test/flutter_test.dart';

import 'package:chevere_plan/core/theme/app_theme.dart';

void main() {
  test('AppTheme.light usa Material 3', () {
    final theme = AppTheme.light();
    expect(theme.useMaterial3, isTrue);
  });
}
