import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import 'app_log.dart';

/// Canal único de errores remotos (Firebase Crashlytics).
///
/// Colección activa en **release/profile** (`!kDebugMode`). En debug no se
/// fuerza (normal que no sea representativo). Auth sigue en Supabase: el
/// [setUserId] usa el UUID de perfil, no email.
class CrashlyticsService {
  CrashlyticsService._();

  static final CrashlyticsService instance = CrashlyticsService._();

  /// Tras [Firebase.initializeApp]: handlers globales + colección según modo.
  static Future<void> installGlobalHandlers() async {
    final crash = FirebaseCrashlytics.instance;
    // Release/profile (publish_beta / APK): sí. Debug: no hace falta forzar.
    await crash.setCrashlyticsCollectionEnabled(!kDebugMode);

    FlutterError.onError = crash.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      unawaited(crash.recordError(error, stack, fatal: true));
      return true;
    };

    // Solo con --dart-define=CRASHLYTICS_SMOKE=true (profile/release).
    if (const bool.fromEnvironment('CRASHLYTICS_SMOKE')) {
      unawaited(() async {
        await CrashlyticsService.instance.recordNonFatal(
          StateError('crashlytics_smoke_test'),
          StackTrace.current,
          context: 'crashlytics_smoke_test',
          keys: const {'smoke': 'true'},
        );
        await FirebaseCrashlytics.instance.sendUnsentReports();
      }());
    }
  }

  Future<void> setUserId(String? userId) async {
    try {
      final id = userId?.trim() ?? '';
      await FirebaseCrashlytics.instance.setUserIdentifier(id);
    } catch (e, st) {
      AppLog.debug(
        'Crashlytics setUserIdentifier',
        name: 'crashlytics',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<void> clearUserId() => setUserId(null);

  /// Error no fatal (p. ej. fallo al guardar sitio) con contexto legible en consola.
  Future<void> recordNonFatal(
    Object error,
    StackTrace? stackTrace, {
    required String context,
    Map<String, String> keys = const {},
  }) async {
    final ctx = context.trim();
    final safeCtx = ctx.isEmpty ? 'unknown' : ctx;
    AppLog.error(
      '$safeCtx: $error',
      name: 'crashlytics',
      error: error,
      stackTrace: stackTrace,
    );

    try {
      final crash = FirebaseCrashlytics.instance;
      await crash.setCustomKey('context', safeCtx);
      for (final e in keys.entries) {
        final k = e.key.trim();
        final v = e.value.trim();
        if (k.isEmpty || v.isEmpty) continue;
        await crash.setCustomKey(k, v);
      }
      await crash.recordError(
        error,
        stackTrace,
        fatal: false,
        reason: safeCtx,
        information: <Object>[
          'context=$safeCtx',
          ...keys.entries
              .where((e) => e.key.trim().isNotEmpty && e.value.trim().isNotEmpty)
              .map((e) => '${e.key.trim()}=${e.value.trim()}'),
        ],
      );
    } catch (e, st) {
      AppLog.debug(
        'Crashlytics recordNonFatal failed',
        name: 'crashlytics',
        error: e,
        stackTrace: st,
      );
    }
  }

  void recordNonFatalAsync(
    Object error,
    StackTrace? stackTrace, {
    required String context,
    Map<String, String> keys = const {},
  }) {
    unawaited(
      recordNonFatal(
        error,
        stackTrace,
        context: context,
        keys: keys,
      ),
    );
  }
}
