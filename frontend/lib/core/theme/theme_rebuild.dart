import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../di/providers.dart';

/// Llama al inicio de `build` para repintar widgets que usan [AppColors].
extension AppThemeRebuildRef on WidgetRef {
  void watchAppThemeMode() => watch(appThemeModeProvider);
}
