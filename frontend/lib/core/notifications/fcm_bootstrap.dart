import 'package:firebase_messaging/firebase_messaging.dart';

import '../logging/app_log.dart';

/// Inicialización mínima de FCM (Ciclo 0). Sin topics ni geofencing.
Future<void> bootstrapFcm() async {
  final messaging = FirebaseMessaging.instance;

  final settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  AppLog.debug(
    'FCM permission: ${settings.authorizationStatus}',
    name: 'fcm',
  );

  try {
    final token = await messaging.getToken();
    // Nunca loguear el token completo (identificador de dispositivo / push).
    AppLog.debug(
      token == null || token.isEmpty
          ? 'FCM token vacío'
          : 'FCM token obtenido (len=${token.length})',
      name: 'fcm',
    );
  } catch (error, stack) {
    AppLog.debug(
      'No se pudo obtener FCM token (normal en emulador sin Play Services)',
      name: 'fcm',
      error: error,
      stackTrace: stack,
    );
  }
}
