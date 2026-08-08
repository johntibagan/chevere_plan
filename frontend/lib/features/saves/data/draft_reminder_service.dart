import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Recordatorios locales de borradores (§3.1).
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
    Duration delay = const Duration(hours: 24),
  }) async {
    await init();
    final id = saveId.hashCode & 0x7fffffff;
    final when = tz.TZDateTime.now(tz.local).add(delay);
    await _plugin.zonedSchedule(
      id: id,
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

  Future<void> cancelForSave(String saveId) async {
    await init();
    final id = saveId.hashCode & 0x7fffffff;
    await _plugin.cancel(id: id);
  }
}
