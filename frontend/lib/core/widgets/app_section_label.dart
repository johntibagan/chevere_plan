import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Encabezado de bloque en tabs (Planes, Rutas, listas).
class AppSectionLabel extends StatelessWidget {
  const AppSectionLabel({
    super.key,
    required this.text,
    this.required = false,
    this.bottom = 12,
  });

  final String text;
  final bool required;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Text.rich(
        TextSpan(
          text: text.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: AppColors.mutedDark,
          ),
          children: [
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(
                  color: AppColors.requiredMark,
                  fontWeight: FontWeight.w800,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
