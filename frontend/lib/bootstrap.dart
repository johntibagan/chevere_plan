import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/auth/secure_session_storage.dart';
import 'core/cache/app_image_cache.dart';
import 'core/cache/entity_cache_store.dart';
import 'core/config/env.dart';
import 'core/logging/app_log.dart';
import 'core/notifications/app_local_notifications.dart';
import 'core/notifications/fcm_bootstrap.dart';
import 'features/proximity/data/proximity_reminder_service.dart';
import 'features/saves/data/draft_reminder_service.dart';

/// Arranque compartido entre `main` y Patrol (sin `ensureInitialized` / `runApp`).
Future<Widget> createRootApp({
  bool initFirebase = true,
  bool initLocalNotifications = true,
  List<Override> overrides = const [],
}) async {
  if (Env.hasInjectedServiceRole) {
    return ProviderScope(
      overrides: overrides,
      child: BootstrapErrorApp(
        message: kReleaseMode
            ? Env.missingConfigUserMessage
            : 'Quitá SUPABASE_SERVICE_ROLE_KEY de frontend/.env. '
                'Esa clave es solo para backend/.env.',
      ),
    );
  }

  if (!Env.hasSupabaseConfig || !Env.supabaseUrlIsHttps) {
    return ProviderScope(
      overrides: overrides,
      child: BootstrapErrorApp(message: Env.missingConfigUserMessage),
    );
  }

  // Caché disco (Hive CE) — fallos no bloquean el arranque.
  try {
    await EntityCacheStore.instance.init();
  } catch (e, st) {
    AppLog.error('Hive init', name: 'bootstrap', error: e, stackTrace: st);
  }

  try {
    AppImageCacheManager.configurePaintingCache();
  } catch (e, st) {
    AppLog.error('image cache', name: 'bootstrap', error: e, stackTrace: st);
  }

  // FCM y notificaciones piden permiso: si se espera aquí, el splash nativo
  // nunca se quita (típico tras borrar datos de la app).
  unawaited(_initPushAndLocalNotifs(
    initFirebase: initFirebase,
    initLocalNotifications: initLocalNotifications,
  ));

  // No usar `Supabase.instance.isInitialized`: acceder a `.instance` exige
  // que ya esté inicializado (assertion en debug).
  try {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      publishableKey: Env.supabaseAnonKey,
      authOptions: FlutterAuthClientOptions(
        localStorage: SecureSessionStorage(supabaseUrl: Env.supabaseUrl),
      ),
    ).timeout(const Duration(seconds: 15));
  } catch (e, st) {
    // Ya inicializado en este proceso (p. ej. test Patrol anterior).
    AppLog.debug(
      'Supabase.initialize skipped',
      name: 'bootstrap',
      error: e,
      stackTrace: st,
    );
  }

  return ProviderScope(
    overrides: overrides,
    child: const CheverePlanApp(),
  );
}

Future<void> _initPushAndLocalNotifs({
  required bool initFirebase,
  required bool initLocalNotifications,
}) async {
  try {
    await Future<void>(() async {
      if (initFirebase) {
        await Firebase.initializeApp();
        await bootstrapFcm();
      }
      if (initLocalNotifications) {
        await AppLocalNotifications.instance.init();
        // Mantienen API de dominio; delegan al plugin único.
        await DraftReminderService.instance.init();
        await ProximityReminderService.instance.init();
      }
    }).timeout(const Duration(seconds: 12));
  } catch (e, st) {
    AppLog.error(
      'push/local notifs bootstrap',
      name: 'bootstrap',
      error: e,
      stackTrace: st,
    );
  }
}

/// Pantalla de error de bootstrap (config faltante).
class BootstrapErrorApp extends StatelessWidget {
  const BootstrapErrorApp({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              message,
              key: const Key('bootstrap_error'),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
