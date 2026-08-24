import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Card de formulario (Guardar sitio y bloques similares).
class AppFormCard extends StatelessWidget {
  const AppFormCard({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final body = Padding(padding: padding, child: child);
    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: onTap == null
          ? body
          : InkWell(onTap: onTap, child: body),
    );
  }
}
