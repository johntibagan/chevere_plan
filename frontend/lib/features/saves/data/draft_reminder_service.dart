import 'package:flutter/widgets.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../core/formatters/place_format.dart';
import '../../../core/l10n/app_locale.dart';
import '../../../core/notifications/app_local_notifications.dart';
import '../../../core/notifications/app_notification_card.dart';
import '../../../core/notifications/notification_cover_cache.dart';
import '../../../core/notifications/notification_kind.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/save_policies.dart';

/// Recordatorios locales de borradores / pendientes (§3.1) — tarjeta estándar.
class DraftReminderService {
  DraftReminderService._();

  static final instance = DraftReminderService._();

  Future<void> init() => AppLocalNotifications.instance.init();

  Future<void> scheduleForSave({
    required String saveId,
    required String title,
    String? city,
    String? department,
    String? coverStoragePath,
    List<Duration> delays = SavePolicies.draftRemindDelays,
  }) async {
    await init();
    await cancelForSave(saveId);

    final l10n = lookupAppLocalizations(const Locale(kAppLocale));
    final name = title.trim().isEmpty ? l10n.notifPlaceFallback : title.trim();
    final place = formatDeptCity(department, city);

    String? imagePath;
    final cover = coverStoragePath?.trim();
    if (cover != null && cover.isNotEmpty) {
      imagePath = await NotificationCoverCache.cacheFromStoragePath(
        cacheKey: 'draft_$saveId',
        storagePath: cover,
      );
    }

    final whenBase = tz.TZDateTime.now(tz.local);
    for (var i = 0; i < delays.length; i++) {
      final when = whenBase.add(delays[i]);
      await AppLocalNotifications.instance.scheduleCard(
        card: AppNotificationCard(
          kind: NotificationKind.draft,
          id: saveId,
          title: name,
          placeLine: place,
          contextLine: l10n.notifDraftContext,
          imageFilePath: imagePath,
          notificationId: _notifId(saveId, i),
        ),
        when: when,
      );
    }
  }

  Future<void> cancelForSave(String saveId) async {
    await init();
    for (var i = 0; i < SavePolicies.draftRemindDelays.length; i++) {
      await AppLocalNotifications.instance.cancel(_notifId(saveId, i));
    }
    // Id legacy (un solo aviso) por si quedó de versiones anteriores.
    await AppLocalNotifications.instance.cancel(saveId.hashCode & 0x7fffffff);
  }

  static int _notifId(String saveId, int slot) {
    return Object.hash(saveId, slot) & 0x7fffffff;
  }
}
