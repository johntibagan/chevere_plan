import 'package:flutter/material.dart';

import '../errors/user_facing_error.dart';
import '../theme/app_theme.dart';

/// Avisos flotantes (toast). Preferir esto a texto de error incrustado en la UI.
abstract final class AppToast {
  static void show(
    BuildContext context,
    String message, {
    bool error = false,
    Duration? duration,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: duration ?? Duration(seconds: error ? 5 : 4),
        backgroundColor: error ? AppColors.accent : AppColors.surfaceElevated,
      ),
    );
  }

  static void error(
    BuildContext context,
    Object err, {
    StackTrace? stackTrace,
    String? logContext,
  }) {
    show(
      context,
      userFacingError(err, stackTrace: stackTrace, context: logContext),
      error: true,
    );
  }
}
