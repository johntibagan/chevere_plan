import 'package:firebase_performance/firebase_performance.dart';

import '../logging/app_log.dart';

/// Performance Monitoring al arrancar. Tokens FCM: [PushNotificationService].
Future<void> bootstrapFcm() async {
  try {
    await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
  } catch (e, st) {
    AppLog.debug(
      'Firebase Performance no disponible',
      name: 'perf',
      error: e,
      stackTrace: st,
    );
  }
}
