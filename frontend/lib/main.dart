import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/env.dart';
import 'core/notifications/fcm_bootstrap.dart';
import 'features/proximity/data/proximity_reminder_service.dart';
import 'features/saves/data/draft_reminder_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Env.assertNoServerSecrets();

  if (!Env.hasSupabaseConfig) {
    runApp(
      ProviderScope(
        child: _BootstrapErrorApp(message: Env.missingConfigUserMessage),
      ),
    );
    return;
  }

  await Firebase.initializeApp();
  await bootstrapFcm();
  await DraftReminderService.instance.init();
  await ProximityReminderService.instance.init();

  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabaseAnonKey,
  );

  runApp(const ProviderScope(child: CheverePlanApp()));
}

class _BootstrapErrorApp extends StatelessWidget {
  const _BootstrapErrorApp({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(message, textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}
