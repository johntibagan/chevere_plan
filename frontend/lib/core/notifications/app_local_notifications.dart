import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../l10n/app_localizations.dart';
import '../l10n/app_locale.dart';
import 'app_notification_card.dart';
import 'local_notification_router.dart';
import 'notification_kind.dart';

/// Plugin único + canales + tarjeta estándar (BigPicture cuando hay foto).
class AppLocalNotifications {
  AppLocalNotifications._();

  static final instance = AppLocalNotifications._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  FlutterLocalNotificationsPlugin get plugin => _plugin;

  AppLocalizations get _l10n =>
      lookupAppLocalizations(const Locale(kAppLocale));

  Future<void> init() async {
    if (_ready) return;
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      settings: const InitializationSettings(android: android),
      onDidReceiveNotificationResponse: (response) {
        LocalNotificationRouter.handlePayload(response.payload);
      },
    );

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    await _ensureChannels(androidPlugin);

    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp == true) {
      LocalNotificationRouter.handlePayload(
        launch!.notificationResponse?.payload,
      );
    }
    _ready = true;
  }

  Future<void> _ensureChannels(
    AndroidFlutterLocalNotificationsPlugin? android,
  ) async {
    if (android == null) return;
    final l10n = _l10n;
    await android.createNotificationChannel(
      AndroidNotificationChannel(
        NotificationKind.proximity.channelId,
        l10n.notifChannelProximityName,
        description: l10n.notifChannelProximityDesc,
        importance: Importance.high,
      ),
    );
    await android.createNotificationChannel(
      AndroidNotificationChannel(
        NotificationKind.draft.channelId,
        l10n.notifChannelDraftName,
        description: l10n.notifChannelDraftDesc,
        importance: Importance.defaultImportance,
      ),
    );
    await android.createNotificationChannel(
      AndroidNotificationChannel(
        NotificationKind.eventInterest.channelId,
        l10n.notifChannelEventName,
        description: l10n.notifChannelEventDesc,
        importance: Importance.defaultImportance,
      ),
    );
    await android.createNotificationChannel(
      AndroidNotificationChannel(
        NotificationKind.monthlySummary.channelId,
        l10n.notifChannelSummaryName,
        description: l10n.notifChannelSummaryDesc,
        importance: Importance.low,
      ),
    );
  }

  Future<void> showCard(AppNotificationCard card) async {
    await init();
    await _plugin.show(
      id: card.resolvedNotificationId,
      title: card.title,
      body: _bodyLine(card),
      payload: card.payload,
      notificationDetails: _detailsFor(card),
    );
  }

  Future<void> scheduleCard({
    required AppNotificationCard card,
    required DateTime when,
  }) async {
    await init();
    final scheduled = tz.TZDateTime.from(when, tz.local);
    await _plugin.zonedSchedule(
      id: card.resolvedNotificationId,
      title: card.title,
      body: _bodyLine(card),
      scheduledDate: scheduled,
      payload: card.payload,
      notificationDetails: _detailsFor(card),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancel(int id) async {
    await init();
    await _plugin.cancel(id: id);
  }

  String _bodyLine(AppNotificationCard card) {
    final place = card.placeLine.trim();
    if (place.isNotEmpty) return place;
    return card.contextLine.trim();
  }

  NotificationDetails _detailsFor(AppNotificationCard card) {
    final l10n = _l10n;
    final channelName = switch (card.kind) {
      NotificationKind.proximity => l10n.notifChannelProximityName,
      NotificationKind.draft => l10n.notifChannelDraftName,
      NotificationKind.eventInterest => l10n.notifChannelEventName,
      NotificationKind.monthlySummary => l10n.notifChannelSummaryName,
    };
    final channelDesc = switch (card.kind) {
      NotificationKind.proximity => l10n.notifChannelProximityDesc,
      NotificationKind.draft => l10n.notifChannelDraftDesc,
      NotificationKind.eventInterest => l10n.notifChannelEventDesc,
      NotificationKind.monthlySummary => l10n.notifChannelSummaryDesc,
    };
    final importance = card.kind == NotificationKind.proximity
        ? Importance.high
        : card.kind == NotificationKind.monthlySummary
            ? Importance.low
            : Importance.defaultImportance;
    final priority = card.kind == NotificationKind.proximity
        ? Priority.high
        : Priority.defaultPriority;

    final imagePath = card.imageFilePath?.trim();
    final hasImage = imagePath != null && imagePath.isNotEmpty && !kIsWeb;

    StyleInformation? style;
    AndroidBitmap<Object>? largeIcon;
    if (hasImage) {
      final bitmap = FilePathAndroidBitmap(imagePath);
      largeIcon = bitmap;
      style = BigPictureStyleInformation(
        bitmap,
        largeIcon: bitmap,
        contentTitle: card.title,
        summaryText: _summaryLine(card),
        htmlFormatContentTitle: false,
        htmlFormatSummaryText: false,
      );
    } else {
      style = BigTextStyleInformation(
        _expandedText(card),
        contentTitle: card.title,
        summaryText: card.contextLine.trim().isEmpty
            ? null
            : card.contextLine.trim(),
        htmlFormatBigText: false,
        htmlFormatContentTitle: false,
        htmlFormatSummaryText: false,
      );
    }

    return NotificationDetails(
      android: AndroidNotificationDetails(
        card.kind.channelId,
        channelName,
        channelDescription: channelDesc,
        importance: importance,
        priority: priority,
        styleInformation: style,
        largeIcon: largeIcon,
        category: AndroidNotificationCategory.reminder,
      ),
    );
  }

  String _summaryLine(AppNotificationCard card) {
    final place = card.placeLine.trim();
    final ctx = card.contextLine.trim();
    if (place.isNotEmpty && ctx.isNotEmpty) return '$place · $ctx';
    if (place.isNotEmpty) return place;
    return ctx;
  }

  String _expandedText(AppNotificationCard card) {
    final place = card.placeLine.trim();
    final ctx = card.contextLine.trim();
    if (place.isNotEmpty && ctx.isNotEmpty) return '$place\n$ctx';
    if (place.isNotEmpty) return place;
    return ctx;
  }
}
