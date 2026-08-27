import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/site_cover.dart';

enum FavoriteHeartStyle { overlay, icon }

/// Corazón de favorito. Relleno = está en `site_favorites` del usuario.
class FavoriteHeartButton extends ConsumerWidget {
  const FavoriteHeartButton({
    super.key,
    required this.siteId,
    this.style = FavoriteHeartStyle.overlay,
  });

  final String siteId;
  final FavoriteHeartStyle style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isFav = ref.watch(
      favoriteSiteIdsProvider.select(
        (async) => async.valueOrNull?.contains(siteId) ?? false,
      ),
    );
    final tooltip = isFav ? l10n.favoriteRemove : l10n.favoriteAdd;

    Future<void> toggle() async {
      try {
        await ref.read(favoriteSiteIdsProvider.notifier).toggle(siteId);
      } catch (e, st) {
        if (context.mounted) {
          AppToast.error(context, e, stackTrace: st, logContext: 'favorite');
        }
      }
    }

    if (style == FavoriteHeartStyle.icon) {
      return IconButton(
        tooltip: tooltip,
        onPressed: toggle,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints.tightFor(width: 28, height: 28),
        iconSize: 20,
        icon: Icon(
          isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: isFav ? AppColors.accent : AppColors.muted,
        ),
      );
    }

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: toggle,
          child: CardHeartBadge(saved: isFav),
        ),
      ),
    );
  }
}
