import 'dart:developer' as developer;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Inicialización mínima de FCM (Ciclo 0). Sin topics ni geofencing.
Future<void> bootstrapFcm() async {
  final messaging = FirebaseMessaging.instance;

  final settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (kDebugMode) {
    developer.log(
      'FCM permission: ${settings.authorizationStatus}',
      name: 'fcm',
    );
  }

  try {
    final token = await messaging.getToken();
    if (kDebugMode) {
      developer.log('FCM token: $token', name: 'fcm');
    }
  } catch (error, stack) {
    developer.log(
      'No se pudo obtener FCM token (normal en emulador sin Play Services)',
      name: 'fcm',
      error: error,
      stackTrace: stack,
    );
  }
}
