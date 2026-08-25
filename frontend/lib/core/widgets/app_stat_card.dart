import 'package:flutter/material.dart';

import '../theme/app_typography.dart';
import '../theme/app_theme.dart';

/// Métrica compacta (Rutas y cualquier tab con 2–3 cifras).
class AppStatCard extends StatelessWidget {
  const AppStatCard({
    super.key,
    required this.value,
    required this.label,
    this.valueColor,
    this.icon,
  });

  final String value;
  final String label;
  final Color? valueColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final accent = valueColor ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          if (icon != null) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 6, bottom: 6),
                child: Icon(icon, size: 16, color: accent),
              ),
            ),
          ],
          Text(
            value,
            style: AppTypography.statValue(color: accent),
          ),
          SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9,
              height: 1.2,
              fontWeight: FontWeight.w600,
              color: AppColors.mutedDark,
            ),
          ),
        ],
      ),
    );
  }
}
