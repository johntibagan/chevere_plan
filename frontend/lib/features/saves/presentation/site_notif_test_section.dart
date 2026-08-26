import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatters/place_format.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/notifications/app_local_notifications.dart';
import '../../../core/notifications/app_notification_card.dart';
import '../../../core/notifications/notification_cover_cache.dart';
import '../../../core/notifications/notification_kind.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_rebuild.dart';
import '../../../core/widgets/app_toast.dart';

/// Chips temporales para probar tarjetas de notificación en la ficha.
/// Minimizable; se elimina al cerrar la etapa de pruebas.
class SiteNotifTestSection extends ConsumerStatefulWidget {
  const SiteNotifTestSection({
    super.key,
    required this.siteId,
    required this.siteName,
    this.city,
    this.department,
    this.coverStoragePath,
    this.draftSaveId,
  });

  final String siteId;
  final String siteName;
  final String? city;
  final String? department;
  final String? coverStoragePath;
  final String? draftSaveId;

  @override
  ConsumerState<SiteNotifTestSection> createState() =>
      _SiteNotifTestSectionState();
}

class _SiteNotifTestSectionState extends ConsumerState<SiteNotifTestSection> {
  var _busy = false;

  Future<void> _fire(NotificationKind kind) async {
    if (_busy) return;
    setState(() => _busy = true);
    final l10n = context.l10n;
    try {
      final place = formatDeptCity(widget.department, widget.city);
      final title = widget.siteName.trim().isEmpty
          ? l10n.notifPlaceFallback
          : widget.siteName.trim();

      String? imagePath;
      final cover = widget.coverStoragePath?.trim();
      if (cover != null && cover.isNotEmpty) {
        imagePath = await NotificationCoverCache.cacheFromStoragePath(
          cacheKey: 'test_${kind.name}_${widget.siteId}',
          storagePath: cover,
        );
      }

      final contextLine = switch (kind) {
        NotificationKind.proximity => l10n.notifProximityContext,
        NotificationKind.draft => l10n.notifDraftContext,
        NotificationKind.eventInterest => l10n.notifEventContext,
        NotificationKind.monthlySummary => l10n.notifSummaryContext,
      };

      final id = switch (kind) {
        NotificationKind.draft =>
          (widget.draftSaveId?.trim().isNotEmpty ?? false)
              ? widget.draftSaveId!.trim()
              : widget.siteId,
        _ => widget.siteId,
      };

      await AppLocalNotifications.instance.showCard(
        AppNotificationCard(
          kind: kind,
          id: id,
          title: title,
          placeLine: place,
          contextLine: contextLine,
          imageFilePath: imagePath,
        ),
      );
      if (!mounted) return;
      AppToast.show(context, l10n.notifTestSent);
    } catch (_) {
      if (!mounted) return;
      AppToast.show(context, l10n.errorProblemToast, error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watchAppThemeMode();
    final l10n = context.l10n;
    return ExpansionTile(
      initiallyExpanded: false,
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 4),
      iconColor: AppColors.muted,
      collapsedIconColor: AppColors.muted,
      title: Text(
        l10n.notifTestSectionTitle,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.muted,
        ),
      ),
      subtitle: Text(
        l10n.notifTestSectionHint,
        style: TextStyle(fontSize: 11, color: AppColors.muted),
      ),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _TestChip(
                label: l10n.notifTestChipProximity,
                onTap: _busy ? null : () => _fire(NotificationKind.proximity),
              ),
              _TestChip(
                label: l10n.notifTestChipDraft,
                onTap: _busy ? null : () => _fire(NotificationKind.draft),
              ),
              _TestChip(
                label: l10n.notifTestChipEvent,
                onTap:
                    _busy ? null : () => _fire(NotificationKind.eventInterest),
              ),
              _TestChip(
                label: l10n.notifTestChipSummary,
                onTap:
                    _busy ? null : () => _fire(NotificationKind.monthlySummary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TestChip extends StatelessWidget {
  const _TestChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label, style: TextStyle(fontSize: 12, color: AppColors.foreground)),
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      backgroundColor: AppColors.surfaceElevated,
      side: BorderSide(color: AppColors.border),
    );
  }
}
