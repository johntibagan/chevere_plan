import 'package:flutter/material.dart';

import '../l10n/context_l10n.dart';
import '../theme/app_theme.dart';

/// Aviso: guardado no físico (tarjeta) no entra en Explorar / planes / rutas.
class NonPhysicalCardBanner extends StatelessWidget {
  const NonPhysicalCardBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.muted.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.style_outlined,
            size: 18,
            color: AppColors.muted,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.nonPhysicalCardWarning,
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
