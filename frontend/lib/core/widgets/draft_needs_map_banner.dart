import 'package:flutter/material.dart';

import '../l10n/context_l10n.dart';
import '../theme/app_theme.dart';

/// Aviso cuando el guardado no tiene pin: no entra en Explorar / planes / rutas.
class DraftNeedsMapBanner extends StatelessWidget {
  const DraftNeedsMapBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 18,
            color: AppColors.warning,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.draftNeedsMapPointWarning,
              style: TextStyle(
                fontSize: 12,
                height: 1.35,
                color: AppColors.foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
