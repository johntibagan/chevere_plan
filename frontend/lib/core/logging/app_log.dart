import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Logging consciente de seguridad: sin tokens/PII en release; sanitizado en debug.
abstract final class AppLog {
  static final RegExp _jwtLike = RegExp(
    r'eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+',
  );
  static final RegExp _bearer = RegExp(
    r'(Bearer\s+)[A-Za-z0-9._\-]+',
    caseSensitive: false,
  );
  static final RegExp _apiKeyQuery = RegExp(
    r'([?&](apiKey|apikey|access_token|token|key)=)[^&\s]+',
    caseSensitive: false,
  );

  static String redact(String input) {
    var out = input;
    out = out.replaceAllMapped(_jwtLike, (_) => 'eyJ…[redacted]');
    out = out.replaceAllMapped(_bearer, (m) => '${m[1]}[redacted]');
    out = out.replaceAllMapped(_apiKeyQuery, (m) => '${m[1]}[redacted]');
    return out;
  }

  static void debug(
    String message, {
    String name = 'app',
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode) return;
    developer.log(
      redact(message),
      name: name,
      error: error == null ? null : redact('$error'),
      stackTrace: stackTrace,
    );
  }

  /// Errores: mensaje sanitizado (también en release, para beta/logcat).
  static void error(
    String message, {
    String name = 'app',
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      redact(message),
      name: name,
      error: error == null ? null : redact('$error'),
      stackTrace: kReleaseMode ? null : stackTrace,
    );
  }
}
