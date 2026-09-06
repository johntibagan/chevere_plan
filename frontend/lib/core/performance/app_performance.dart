import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_performance/firebase_performance.dart';

import '../logging/app_log.dart';

/// Traces custom de Firebase Performance (contenido visible, no solo “pantalla abierta”).
///
/// No-op si Firebase aún no está listo (tests / arranque temprano).
abstract final class AppPerformance {
  static const homeTimeToContent = 'home_time_to_content';
  static const searchTimeToFirstResults = 'search_time_to_first_results';
  static const siteDetailTimeToContent = 'site_detail_time_to_content';

  static final Map<String, Trace> _active = {};

  /// Arranca (o reinicia) un trace con [name].
  static Future<void> start(String name) async {
    try {
      if (Firebase.apps.isEmpty) return;
      final previous = _active.remove(name);
      if (previous != null) {
        await previous.stop();
      }
      final trace = FirebasePerformance.instance.newTrace(name);
      await trace.start();
      _active[name] = trace;
    } catch (e, st) {
      AppLog.debug(
        'perf start $name',
        name: 'perf',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Detiene el trace si sigue activo. Idempotente.
  static Future<void> stop(String name) async {
    try {
      final trace = _active.remove(name);
      if (trace == null) return;
      await trace.stop();
    } catch (e, st) {
      AppLog.debug(
        'perf stop $name',
        name: 'perf',
        error: e,
        stackTrace: st,
      );
    }
  }
}
