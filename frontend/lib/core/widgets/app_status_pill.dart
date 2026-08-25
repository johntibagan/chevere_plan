import 'package:flutter/material.dart';

import '../theme/app_radius.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';

/// Pill de estado (borrador vs próximo, etc.).
class AppStatusPill extends StatelessWidget {
  const AppStatusPill({
    super.key,
    required this.label,
    this.emphasized = true,
  });

  final String label;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: emphasized ? AppColors.primary : AppColors.scrim,
        borderRadius: AppRadius.pillAll,
      ),
      child: Text(
        label,
        style: AppTypography.microBold(
          color: emphasized ? AppColors.onPrimary : AppColors.muted,
        ),
      ),
    );
  }
}
