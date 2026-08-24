import 'package:flutter/material.dart';

import '../l10n/context_l10n.dart';
import '../theme/app_theme.dart';

/// Indicador de privacidad. Por defecto **solo icono** (el color ya comunica;
/// no repetir etiqueta de visibilidad si hay borde de color en la tarjeta).
class VisibilityBadge extends StatelessWidget {
  const VisibilityBadge({
    super.key,
    required this.isPublic,
    this.compact = false,
    this.showLabel = false,
  });

  final bool isPublic;
  final bool compact;
  /// Solo cuando no hay otra señal de color (borde/franja). Preferir false.
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final color = isPublic ? AppColors.success : AppColors.purple;
    // Accesibilidad: sin palabras «Público»/«Privado» (el color ya lo dice).
    final tooltip = isPublic
        ? l10n.visibilityTooltipPublic
        : l10n.visibilityTooltipPrivate;
    final icon = isPublic ? Icons.public : Icons.lock_outline;

    final child = showLabel
        ? Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 8 : 10,
              vertical: compact ? 3 : 5,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: color.withValues(alpha: 0.45)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: compact ? 12 : 14, color: color),
                SizedBox(width: compact ? 4 : 6),
                Text(
                  tooltip,
                  style: TextStyle(
                    fontSize: compact ? 11 : 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          )
        : Icon(icon, size: compact ? 16 : 18, color: color);

    return Tooltip(
      message: tooltip,
      child: child,
    );
  }
}

/// Franja izquierda verde/morado. Usar en cards; no repetir la palabra Público/Privado.
class VisibilityStripe extends StatelessWidget {
  const VisibilityStripe({
    super.key,
    required this.isPublic,
    this.width = 3,
  });

  final bool isPublic;
  final double width;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: isPublic ? AppColors.success : AppColors.purple,
      child: SizedBox(width: width),
    );
  }
}
