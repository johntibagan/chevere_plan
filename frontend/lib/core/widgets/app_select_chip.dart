import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Chip de filtro (Explorar y cualquier lista con “Todos” + opciones).
class AppSelectChip extends StatelessWidget {
  const AppSelectChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.accent,
    this.filledPrimary = false,
    this.icon,
    this.showCheckWhenSelected = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  /// Color de categoría cuando está seleccionado (si no, primary).
  final Color? accent;
  /// “Todos”: fondo primary y texto oscuro.
  final bool filledPrimary;
  final IconData? icon;
  /// Check a la izquierda cuando [selected] (multi-select).
  final bool showCheckWhenSelected;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final Color border;
    if (selected && filledPrimary) {
      bg = AppColors.primary;
      fg = AppColors.background;
      border = AppColors.primary;
    } else if (selected) {
      final c = accent ?? AppColors.primary;
      bg = c.withValues(alpha: 0.13);
      fg = c;
      border = c.withValues(alpha: 0.27);
    } else {
      bg = AppColors.surface;
      fg = AppColors.muted;
      border = AppColors.border;
    }

    final leading = selected && showCheckWhenSelected
        ? Icons.check_rounded
        : icon;

    return Material(
      color: bg,
      shape: StadiumBorder(side: BorderSide(color: border)),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[
                Icon(leading, size: 14, color: fg),
                SizedBox(width: 5),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
