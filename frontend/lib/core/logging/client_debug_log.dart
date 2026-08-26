import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_log.dart';

/// Envía errores de prueba a `client_debug_logs` (Supabase) para diagnóstico remoto.
/// Fire-and-forget: nunca tumba el flujo de la app.
abstract final class ClientDebugLog {
  static String _clip(String s, int max) {
    final t = s.trim();
    if (t.length <= max) return t;
    return t.substring(0, max);
  }

  static Future<void> report({
    required String context,
    required Object error,
    StackTrace? stackTrace,
    String? message,
    SupabaseClient? client,
  }) async {
    final raw = (message ?? '$error').trim();
    final safeMsg = AppLog.redact(
      raw.isEmpty ? error.runtimeType.toString() : raw,
    );
    final detail = stackTrace == null
        ? null
        : _clip(AppLog.redact(stackTrace.toString()), 3500);

    AppLog.error(
      safeMsg,
      name: context,
      error: error,
      stackTrace: stackTrace,
    );

    try {
      final c = client ?? Supabase.instance.client;
      final uid = c.auth.currentUser?.id;
      await c.from('client_debug_logs').insert({
        'user_id': uid,
        'context': _clip(context, 120),
        'message': _clip(safeMsg, 2000),
        'error_type': error.runtimeType.toString(),
        'detail': detail,
        'status': 'pending',
      });
    } catch (e, st) {
      AppLog.debug(
        'client_debug_logs insert failed',
        name: 'debug_log',
        error: e,
        stackTrace: st,
      );
    }
  }

  static void reportAsync({
    required String context,
    required Object error,
    StackTrace? stackTrace,
    String? message,
    SupabaseClient? client,
  }) {
    unawaited(
      report(
        context: context,
        error: error,
        stackTrace: stackTrace,
        message: message,
        client: client,
      ),
    );
  }
}
