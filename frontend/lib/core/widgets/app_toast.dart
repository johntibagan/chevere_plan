import 'package:flutter/material.dart';

import '../errors/user_facing_error.dart';
import '../theme/app_theme.dart';

/// Avisos flotantes de **confirmación** o validación de formulario.
/// Los errores técnicos no van aquí: [AppRetryCallout] en el bloque que falló.
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

  /// Solo log. La UI de error es [AppRetryCallout], no un snackbar.
  static void error(
    BuildContext context,
    Object err, {
    StackTrace? stackTrace,
    String? logContext,
  }) {
    userFacingError(err, stackTrace: stackTrace, context: logContext);
    if (!context.mounted) return;
  }
}
