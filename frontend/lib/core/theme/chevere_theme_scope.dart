import 'package:flutter/material.dart';

import 'chevere_theme_colors.dart';

/// Propaga cambios de paleta a widgets que llamen [ChevereThemeScope.of].
class ChevereThemeScope extends InheritedWidget {
  const ChevereThemeScope({
    super.key,
    required this.colors,
    required super.child,
  });

  final ChevereThemeColors colors;

  static ChevereThemeColors of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ChevereThemeScope>();
    if (scope != null) return scope.colors;
    return Theme.of(context).extension<ChevereThemeColors>() ??
        ChevereThemeColors.dark;
  }

  @override
  bool updateShouldNotify(ChevereThemeScope oldWidget) =>
      colors != oldWidget.colors;
}

extension ChevereThemeColorsX on BuildContext {
  ChevereThemeColors get chevereColors => ChevereThemeScope.of(this);
}

/// Registra dependencia de tema (Material + scope) para repintar al cambiar paleta.
class AppThemeDependent extends StatelessWidget {
  const AppThemeDependent({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    ChevereThemeScope.of(context);
    return child;
  }
}
