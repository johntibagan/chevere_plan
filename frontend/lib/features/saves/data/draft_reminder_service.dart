import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../domain/save_policies.dart';

/// Recordatorios locales de borradores / pendientes (§3.1).
class DraftReminderService {
  DraftReminderService._();

  static final instance = DraftReminderService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      settings: const InitializationSettings(android: android),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    _ready = true;
  }

  Future<void> scheduleForSave({
    required String saveId,
    required String title,
    List<Duration> delays = SavePolicies.draftRemindDelays,
  }) async {
    await init();
    await cancelForSave(saveId);
    final whenBase = tz.TZDateTime.now(tz.local);
    for (var i = 0; i < delays.length; i++) {
      final when = whenBase.add(delays[i]);
      await _plugin.zonedSchedule(
        id: _notifId(saveId, i),
        title: 'Completa tu guardado',
        body: 'Todavía tienes un borrador: $title',
        scheduledDate: when,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'draft_reminders',
            'Recordatorios de borradores',
            channelDescription:
                'Te recuerda completar lugares guardados incompletos',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  Future<void> cancelForSave(String saveId) async {
    await init();
    for (var i = 0; i < SavePolicies.draftRemindDelays.length; i++) {
      await _plugin.cancel(id: _notifId(saveId, i));
    }
    // Id legacy (un solo aviso) por si quedó de versiones anteriores.
    await _plugin.cancel(id: saveId.hashCode & 0x7fffffff);
  }

  static int _notifId(String saveId, int slot) {
    return Object.hash(saveId, slot) & 0x7fffffff;
  }
}
