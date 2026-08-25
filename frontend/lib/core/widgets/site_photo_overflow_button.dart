import 'package:flutter/material.dart';

import '../l10n/context_l10n.dart';
import '../theme/app_theme.dart';

/// Menú ⋮ de una foto: solo en el visor a pantalla completa.
class SitePhotoOverflowButton extends StatelessWidget {
  const SitePhotoOverflowButton({
    super.key,
    required this.onSelected,
    required this.canDelete,
    required this.canSetCover,
    required this.isCover,
    this.enabled = true,
  });

  final ValueChanged<String> onSelected;
  final bool canDelete;
  final bool canSetCover;
  final bool isCover;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Material(
      color: AppColors.scrim,
      shape: const CircleBorder(),
      child: PopupMenuButton<String>(
        enabled: enabled,
        padding: EdgeInsets.zero,
        tooltip: l10n.sitePhotoMenuTooltip,
        icon: const Icon(Icons.more_vert, color: AppColors.onImage, size: 20),
        onSelected: onSelected,
        itemBuilder: (context) => [
          if (canSetCover)
            PopupMenuItem(
              value: 'cover',
              enabled: !isCover,
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  isCover ? Icons.check_circle_outline : Icons.image_outlined,
                ),
                title: Text(
                  isCover ? l10n.sitePhotoAlreadyCover : l10n.sitePhotoSetAsCover,
                ),
              ),
            ),
          if (canDelete)
            PopupMenuItem(
              value: 'delete',
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.delete_outline),
                title: Text(l10n.actionDelete),
              ),
            ),
          PopupMenuItem(
            value: 'report',
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.flag_outlined),
              title: Text(l10n.actionReport),
            ),
          ),
        ],
      ),
    );
  }
}
