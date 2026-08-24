import 'package:flutter/material.dart';

import '../prefs/feed_layout.dart';
import '../theme/app_theme.dart';

/// Lista o cuadrícula 2 / 3 / 4 (Inicio y Explorar).
class AppFeedLayoutToggle extends StatelessWidget {
  const AppFeedLayoutToggle({
    super.key,
    required this.value,
    required this.onChanged,
    required this.listTooltip,
    required this.grid2Tooltip,
    required this.grid3Tooltip,
    required this.grid4Tooltip,
  });

  final FeedLayout value;
  final ValueChanged<FeedLayout> onChanged;
  final String listTooltip;
  final String grid2Tooltip;
  final String grid3Tooltip;
  final String grid4Tooltip;

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
              icon: Icons.view_agenda_rounded,
              selected: value == FeedLayout.list,
              tooltip: listTooltip,
              onTap: () => onChanged(FeedLayout.list),
            ),
            _ModeBtn(
              icon: Icons.grid_view_rounded,
              selected: value == FeedLayout.grid2,
              tooltip: grid2Tooltip,
              onTap: () => onChanged(FeedLayout.grid2),
            ),
            _ModeBtn(
              icon: Icons.grid_on_rounded,
              selected: value == FeedLayout.grid3,
              tooltip: grid3Tooltip,
              onTap: () => onChanged(FeedLayout.grid3),
            ),
            _ModeBtn(
              icon: Icons.apps_rounded,
              selected: value == FeedLayout.grid4,
              tooltip: grid4Tooltip,
              onTap: () => onChanged(FeedLayout.grid4),
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
    required this.tooltip,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
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
      ),
    );
  }
}
