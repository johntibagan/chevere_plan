import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/context_l10n.dart';
import '../shell/shell_menu_bridge.dart';
import '../testing/widget_keys.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';
import '../theme/theme_rebuild.dart';
import 'app_network_image.dart';

/// Avatar circular (foto o inicial).
class AppUserAvatar extends StatelessWidget {
  const AppUserAvatar({
    super.key,
    required this.initial,
    this.avatarUrl,
    this.size = 36,
  });

  final String initial;
  final String? avatarUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl?.trim();
    final letter = initial.trim().isEmpty ? 'U' : initial.trim()[0].toUpperCase();
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: url != null && url.isNotEmpty
            ? AppNetworkImage(url: url, width: size, height: size)
            : ColoredBox(
                color: AppColors.primary.withValues(alpha: 0.2),
                child: Center(
                  child: Text(
                    letter,
                    style: AppTypography.cardTitle(color: AppColors.primary)
                        .copyWith(fontSize: size * 0.42),
                  ),
                ),
              ),
      ),
    );
  }
}

/// Botón de cabecera: foto de perfil → abre el menú lateral.
class AppMenuAvatarButton extends ConsumerWidget {
  const AppMenuAvatarButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watchAppThemeMode();
    final bridge = ref.watch(shellMenuBridgeProvider);
    final l10n = context.l10n;

    return Tooltip(
      message: l10n.moreMenuOpenTooltip,
      child: Material(
        key: WidgetKeys.homeMoreMenu,
        color: AppColors.surface,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: bridge.openMoreMenu,
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              child: AppUserAvatar(
                initial: bridge.initial,
                avatarUrl: bridge.avatarUrl,
                size: 34,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
