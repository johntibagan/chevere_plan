import 'package:flutter/material.dart';

import '../l10n/context_l10n.dart';
import '../theme/app_theme.dart';

/// Fallo de carga o de una acción: el usuario toca para reintentar.
///
/// Nunca mostrar "failed", PostgREST ni toasts de error. El detalle va a logs.
class AppRetryCallout extends StatelessWidget {
  const AppRetryCallout({
    super.key,
    required this.onRetry,
    this.padding = const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
  });

  final VoidCallback onRetry;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onRetry,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: padding,
          child: Text(
            l10n.errorGeneric,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.muted,
              height: 1.4,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
