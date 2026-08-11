import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/env.dart';
import 'core/notifications/fcm_bootstrap.dart';
import 'features/proximity/data/proximity_reminder_service.dart';
import 'features/saves/data/draft_reminder_service.dart';

/// Arranque compartido entre `main` y Patrol (sin `ensureInitialized` / `runApp`).
Future<Widget> createRootApp({
  bool initFirebase = true,
  bool initLocalNotifications = true,
  List<Override> overrides = const [],
}) async {
  Env.assertNoServerSecrets();

  if (!Env.hasSupabaseConfig) {
    return ProviderScope(
      overrides: overrides,
      child: BootstrapErrorApp(message: Env.missingConfigUserMessage),
    );
  }

  if (initFirebase) {
    await Firebase.initializeApp();
    await bootstrapFcm();
  }
  if (initLocalNotifications) {
    await DraftReminderService.instance.init();
    await ProximityReminderService.instance.init();
  }

  // No usar `Supabase.instance.isInitialized`: acceder a `.instance` exige
  // que ya esté inicializado (assertion en debug).
  try {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      publishableKey: Env.supabaseAnonKey,
    );
  } catch (_) {
    // Ya inicializado en este proceso (p. ej. test Patrol anterior).
  }

  return ProviderScope(
    overrides: overrides,
    child: const CheverePlanApp(),
  );
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
