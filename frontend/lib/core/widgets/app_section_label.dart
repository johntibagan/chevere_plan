import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Encabezado de bloque en tabs (Planes, Rutas, listas).
class AppSectionLabel extends StatelessWidget {
  const AppSectionLabel({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: AppColors.mutedDark,
        ),
      ),
    );
  }
}
