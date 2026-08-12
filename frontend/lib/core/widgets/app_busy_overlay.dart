import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Barrera modal de carga: el usuario no puede tocar nada hasta que termine [action].
abstract final class AppBusyOverlay {
  static Future<T> run<T>(
    BuildContext context, {
    required Future<T> Function() action,
    String? message,
  }) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (ctx) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            backgroundColor: AppColors.surface,
            content: Row(
              children: [
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    message ?? 'Cargando…',
                    style: const TextStyle(color: AppColors.foreground),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    try {
      return await action();
    } finally {
      if (navigator.canPop()) {
        navigator.pop();
      }
    }
  }
}
