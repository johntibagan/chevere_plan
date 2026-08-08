import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Notificaciones de recuerdo por proximidad (§6).
class ProximityReminderService {
  ProximityReminderService._();

  static final instance = ProximityReminderService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      settings: const InitializationSettings(android: android),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            'proximity_reminders',
            'Recuerdos cercanos',
            description: 'Avisos cuando estás cerca de un lugar guardado',
            importance: Importance.high,
          ),
        );
    _ready = true;
  }

  Future<void> showNearby({required String siteName}) async {
    await init();
    final id = siteName.hashCode & 0x7fffffff;
    await _plugin.show(
      id: id,
      title: 'Chevere Plan',
      body: 'Tienes guardado un lugar cerca de aquí: $siteName',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'proximity_reminders',
          'Recuerdos cercanos',
          channelDescription:
              'Avisos cuando estás cerca de un lugar guardado',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}
