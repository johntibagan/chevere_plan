import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Tag visual público / privado (estilo Figma: color + icono).
class VisibilityBadge extends StatelessWidget {
  const VisibilityBadge({
    super.key,
    required this.isPublic,
    this.compact = false,
  });

  final bool isPublic;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = isPublic ? AppColors.success : AppColors.purple;
    final bg = color.withValues(alpha: 0.16);
    final label = isPublic ? 'Público' : 'Privado';
    final icon = isPublic ? Icons.public : Icons.lock_outline;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 12 : 14, color: color),
          SizedBox(width: compact ? 4 : 6),
          Text(
            label,
            style: TextStyle(
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
