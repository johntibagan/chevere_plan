import 'package:flutter/material.dart';

/// Ícono-acción dentro de un TextField (pegar, buscar). No es decorativo.
class FieldActionIcon extends StatelessWidget {
  const FieldActionIcon({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.loading = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon),
    );
  }
}
