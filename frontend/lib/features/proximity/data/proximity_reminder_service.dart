import '../../../core/formatters/place_format.dart';
import '../../../core/notifications/app_local_notifications.dart';
import '../../../core/notifications/app_notification_card.dart';
import '../../../core/notifications/notification_kind.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/l10n/app_locale.dart';
import 'package:flutter/widgets.dart';

/// Notificaciones de recuerdo por proximidad (§6) — tarjeta estándar.
class ProximityReminderService {
  ProximityReminderService._();

  static final instance = ProximityReminderService._();

  Future<void> init() => AppLocalNotifications.instance.init();

  Future<void> showNearby({
    required String siteId,
    required String siteName,
    String? city,
    String? department,
    String? imageFilePath,
  }) async {
    final l10n = lookupAppLocalizations(const Locale(kAppLocale));
    final name = siteName.trim().isEmpty ? l10n.notifPlaceFallback : siteName.trim();
    final place = formatDeptCity(department, city);
    await AppLocalNotifications.instance.showCard(
      AppNotificationCard(
        kind: NotificationKind.proximity,
        id: siteId,
        title: name,
        placeLine: place,
        contextLine: l10n.notifProximityContext,
        imageFilePath: imageFilePath,
        notificationId: siteId.hashCode & 0x7fffffff,
      ),
    );
  }
}
