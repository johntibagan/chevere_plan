import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Posición estándar de botones flotantes (FAB) sobre anclas inferiores.
///
/// - Tab del shell (`HomePage`): [aboveShellBottomNav].
/// - Stack que termina encima de una barra fija (p. ej. pie del detalle de plan):
///   [aboveFixedBottomBar] — solo el gap, la barra ya está fuera del Stack.
/// - Pantalla completa sin nav del shell: safe area + gap.
abstract final class AppFloatingActionLayout {
  AppFloatingActionLayout._();

  /// Nav inferior del shell (`_ChevereBottomNav` en [HomePage]).
  static const shellBottomNavHeight = 64.0;

  /// Separación entre el borde superior del ancla y el borde inferior del FAB.
  static const gapAboveAnchor = 12.0;

  static const horizontalInset = AppSpacing.lg;

  static const standardFabSize = 56.0;

  static const extendedFabHeight = 56.0;

  /// Reserva inferior típica de listas sobre barra fija de acciones (detalle plan).
  static const fixedBottomBarClearance = 88.0;

  static double bottomOffset(
    BuildContext context, {
    bool aboveShellBottomNav = false,
    bool aboveFixedBottomBar = false,
  }) {
    if (aboveShellBottomNav) {
      return MediaQuery.paddingOf(context).bottom +
          shellBottomNavHeight +
          gapAboveAnchor;
    }
    if (aboveFixedBottomBar) {
      return gapAboveAnchor;
    }
    return MediaQuery.paddingOf(context).bottom + gapAboveAnchor;
  }

  /// Padding inferior de scroll cuando hay un FAB en el mismo [Stack].
  static double listScrollPadding(
    BuildContext context, {
    bool aboveShellBottomNav = false,
    bool aboveFixedBottomBar = false,
    bool extendedFab = false,
  }) {
    final fabHeight = extendedFab ? extendedFabHeight : standardFabSize;
    return bottomOffset(
          context,
          aboveShellBottomNav: aboveShellBottomNav,
          aboveFixedBottomBar: aboveFixedBottomBar,
        ) +
        fabHeight +
        gapAboveAnchor;
  }
}

/// [Positioned] estándar para un FAB (derecha, margen sobre ancla inferior).
class AppAnchoredFloatingAction extends StatelessWidget {
  const AppAnchoredFloatingAction({
    super.key,
    required this.child,
    this.aboveShellBottomNav = false,
    this.aboveFixedBottomBar = false,
  });

  final Widget child;
  final bool aboveShellBottomNav;
  final bool aboveFixedBottomBar;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: AppFloatingActionLayout.horizontalInset,
      bottom: AppFloatingActionLayout.bottomOffset(
        context,
        aboveShellBottomNav: aboveShellBottomNav,
        aboveFixedBottomBar: aboveFixedBottomBar,
      ),
      child: child,
    );
  }
}
