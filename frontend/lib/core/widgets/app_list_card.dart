import 'package:flutter/material.dart';

/// Card de lista con margen inferior estándar (pantallas listado).
class AppListCard extends StatelessWidget {
  const AppListCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: child,
    );
  }
}
