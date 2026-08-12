import 'package:flutter/material.dart';

/// Cuerpo de lista con pull-to-refresh: loading / error / vacío / contenido.
///
/// El [child] debe ser scrollable (p. ej. [ListView]) para que [RefreshIndicator]
/// funcione también en estados vacíos (este widget ya usa ListView en esos casos).
class AppAsyncBody extends StatelessWidget {
  const AppAsyncBody({
    super.key,
    required this.loading,
    required this.onRefresh,
    required this.isEmpty,
    required this.emptyMessage,
    required this.child,
    this.error,
    this.emptyAction,
  });

  final bool loading;
  final String? error;
  final bool isEmpty;
  final String emptyMessage;
  final Future<void> Function() onRefresh;
  final Widget child;
  /// CTA opcional bajo el mensaje vacío (p. ej. "Crear plan").
  final Widget? emptyAction;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: loading
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 120),
                Center(child: CircularProgressIndicator()),
              ],
            )
          : error != null
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  children: const [
                    SizedBox(height: 48),
                    Text(
                      'No se pudo cargar. Desliza para reintentar.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              : isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
                      children: [
                        const SizedBox(height: 48),
                        Text(emptyMessage, textAlign: TextAlign.center),
                        if (emptyAction != null) ...[
                          const SizedBox(height: 24),
                          Center(child: emptyAction!),
                        ],
                      ],
                    )
                  : child,
    );
  }
}
