import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Indicador de privacidad. Por defecto **solo icono** (el color ya comunica;
/// no repetir «Público»/«Privado» si hay borde de color en la tarjeta).
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
    final color = isPublic ? AppColors.success : AppColors.purple;
    final label = isPublic ? 'Público' : 'Privado';
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
                  label,
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
      message: label,
      child: child,
    );
  }
}
