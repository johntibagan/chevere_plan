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
    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.errorGenericLead,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.muted,
              height: 1.4,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 8),
          TextButton.icon(
            onPressed: onRetry,
            icon: Icon(Icons.refresh, size: 18),
            label: Text(
              l10n.errorRetryAction,
              style: TextStyle(
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
