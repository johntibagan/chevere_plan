import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/app_typography.dart';
import 'app_menu_avatar_button.dart';

class TabScreenHeader extends StatelessWidget {
  const TabScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showMenuAvatar = true,
  });

  final String title;
  final String? subtitle;
  /// Foto de perfil → menú lateral (todas las pestañas del shell).
  final bool showMenuAvatar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.tabTitle()),
                if (subtitle != null && subtitle!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      subtitle!,
                      style: AppTypography.bodySecondary(),
                    ),
                  ),
              ],
            ),
          ),
          if (showMenuAvatar) const AppMenuAvatarButton(),
        ],
      ),
    );
  }
}

class AppRoundIconButton extends StatelessWidget {
  const AppRoundIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.selected = false,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool selected;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final child = Material(
      color: selected
          ? AppColors.primary.withValues(alpha: 0.18)
          : AppColors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            size: 20,
            color: selected ? AppColors.primary : AppColors.muted,
          ),
        ),
      ),
    );
    if (tooltip == null) return child;
    return Tooltip(message: tooltip!, child: child);
  }
}

/// Botón 44×44 redondeado (filtros al lado del buscador).
class AppSquareIconButton extends StatelessWidget {
  const AppSquareIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.selected = false,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool selected;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final child = SizedBox(
      width: 44,
      height: 44,
      child: Material(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.18)
            : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Icon(
            icon,
            size: 16,
            color: selected ? AppColors.primary : AppColors.muted,
          ),
        ),
      ),
    );
    if (tooltip == null) return child;
    return Tooltip(message: tooltip!, child: child);
  }
}
