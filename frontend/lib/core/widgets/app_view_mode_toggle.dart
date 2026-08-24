import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Grilla / lista en un solo control (Explorar y listas similares).
class AppViewModeToggle extends StatelessWidget {
  const AppViewModeToggle({
    super.key,
    required this.gridSelected,
    required this.onGrid,
    required this.onList,
    this.gridTooltip,
    this.listTooltip,
  });

  final bool gridSelected;
  final VoidCallback onGrid;
  final VoidCallback onList;
  final String? gridTooltip;
  final String? listTooltip;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ModeBtn(
              icon: Icons.grid_view_rounded,
              selected: gridSelected,
              tooltip: gridTooltip,
              onTap: onGrid,
            ),
            _ModeBtn(
              icon: Icons.view_agenda_rounded,
              selected: !gridSelected,
              tooltip: listTooltip,
              onTap: onList,
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeBtn extends StatelessWidget {
  const _ModeBtn({
    required this.icon,
    required this.selected,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final btn = Material(
      color: selected ? AppColors.surfaceElevated : Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 14,
            color: selected ? AppColors.primary : AppColors.mutedDark,
          ),
        ),
      ),
    );
    if (tooltip == null) return btn;
    return Tooltip(message: tooltip!, child: btn);
  }
}
