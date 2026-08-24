import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

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
        color: emphasized ? AppColors.primary : const Color(0x99000000),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: emphasized ? AppColors.background : AppColors.muted,
        ),
      ),
    );
  }
}
