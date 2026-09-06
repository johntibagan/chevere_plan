import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../logging/app_log.dart';

/// Inicialización de Supabase **sin** bloquear `runApp`.
///
/// El primer frame puede pintar con sesión/Hive optimistas; las mutaciones y
/// repos que usan [Supabase.instance] deben [await ready] (o comprobar
/// [isReady]) antes de tocar el cliente.
abstract final class SupabaseBootstrap {
  static Completer<void>? _gate;
  static Future<void>? _init;
  static var _completed = false;

  /// `true` solo si [initialize] terminó OK (o el SDK ya estaba listo).
  static bool get isReady => _completed;

  /// Completa cuando termina el intento de [start] (éxito o fallo logueado).
  ///
  /// Si aún no llamaron [start], espera a que arranque (no resuelve vacío).
  static Future<void> get ready async {
    final gate = _gate ??= Completer<void>();
    return gate.future;
  }

  /// Dispara [Supabase.initialize] en background. Idempotente.
  static Future<void> start({
    required String url,
    required String publishableKey,
    required LocalStorage localStorage,
  }) {
    final existing = _init;
    if (existing != null) return existing;

    _gate ??= Completer<void>();
    _init = _run(
      url: url,
      publishableKey: publishableKey,
      localStorage: localStorage,
    );
    return _init!;
  }

  static Future<void> _run({
    required String url,
    required String publishableKey,
    required LocalStorage localStorage,
  }) async {
    try {
      await Supabase.initialize(
        url: url,
        publishableKey: publishableKey,
        authOptions: FlutterAuthClientOptions(
          localStorage: localStorage,
        ),
      ).timeout(const Duration(seconds: 15));
      _completed = true;
    } catch (e, st) {
      // Ya inicializado en este proceso (p. ej. test Patrol anterior) u otro fallo.
      AppLog.debug(
        'Supabase.initialize skipped/deferred',
        name: 'bootstrap',
        error: e,
        stackTrace: st,
      );
      try {
        // ignore: unnecessary_statements
        Supabase.instance;
        _completed = true;
      } catch (_) {
        _completed = false;
      }
    } finally {
      final gate = _gate;
      if (gate != null && !gate.isCompleted) {
        gate.complete();
      }
    }
  }

  /// Para tests: espera cliente usable o lanza.
  static Future<void> ensureReady() async {
    await ready;
    if (!_completed) {
      throw StateError('Supabase failed to initialize');
    }
  }
}
