import 'package:flutter/material.dart';

import '../theme/app_radius.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';
import '../theme/chevere_theme_scope.dart';

/// Tono visual del diálogo de confirmación (icono + acento).
enum AppConfirmTone { info, warning, danger, success }

/// Acción de [showAppConfirmDialog].
///
/// **2** acciones → una fila; la [isPrimary] a la **derecha**.
/// **3+** → una columna; la [isPrimary] **al final**.
class AppConfirmAction<T> {
  const AppConfirmAction({
    required this.label,
    required this.value,
    this.isPrimary = false,
    this.isDestructive = false,
    this.key,
  });

  final String label;
  final T value;
  final bool isPrimary;
  final bool isDestructive;
  final Key? key;
}

/// Diálogo de confirmación / aviso estándar de Chevere Plan.
Future<T?> showAppConfirmDialog<T>({
  required BuildContext context,
  required IconData icon,
  required String title,
  required List<AppConfirmAction<T>> actions,
  String? body,
  Widget? bodyWidget,
  AppConfirmTone tone = AppConfirmTone.info,
  Key? dialogKey,
  bool barrierDismissible = true,
}) {
  assert(
    body != null || bodyWidget != null,
    'body o bodyWidget requerido',
  );
  assert(actions.isNotEmpty, 'al menos una acción');

  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (ctx) => AppConfirmDialog<T>(
      key: dialogKey,
      icon: icon,
      title: title,
      body: body,
      bodyWidget: bodyWidget,
      actions: actions,
      tone: tone,
    ),
  );
}

/// Tarjeta de confirmación: icono + título + texto + acciones.
class AppConfirmDialog<T> extends StatelessWidget {
  const AppConfirmDialog({
    super.key,
    required this.icon,
    required this.title,
    required this.actions,
    this.body,
    this.bodyWidget,
    this.tone = AppConfirmTone.info,
  });

  final IconData icon;
  final String title;
  final String? body;
  final Widget? bodyWidget;
  final List<AppConfirmAction<T>> actions;
  final AppConfirmTone tone;

  /// Solo el icono usa el tono; el botón primario siempre es azul de marca
  /// (salvo [AppConfirmAction.isDestructive] → rojo).
  Color get _iconAccent => switch (tone) {
        AppConfirmTone.info => AppColors.primary,
        AppConfirmTone.warning => AppColors.warning,
        AppConfirmTone.danger => AppColors.accent,
        AppConfirmTone.success => AppColors.success,
      };

  @override
  Widget build(BuildContext context) {
    ChevereThemeScope.of(context);
    final primary = actions.where((a) => a.isPrimary).toList();
    final rest = actions.where((a) => !a.isPrimary).toList();
    final layoutActions = [...rest, ...primary];

    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _iconAccent.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22, color: _iconAccent),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                title,
                style: AppTypography.cardTitle(color: AppColors.foreground),
              ),
            ),
          ),
        ],
      ),
      content: bodyWidget ??
          Text(
            body!,
            style: TextStyle(
              fontSize: 14,
              height: 1.35,
              color: AppColors.muted,
            ),
          ),
      actions: [
        SizedBox(
          width: double.maxFinite,
          child: layoutActions.length <= 2
              ? _ActionsRow(actions: layoutActions)
              : _ActionsColumn(actions: layoutActions),
        ),
      ],
      actionsAlignment: MainAxisAlignment.center,
    );
  }
}

class _ActionsRow<T> extends StatelessWidget {
  const _ActionsRow({required this.actions});

  final List<AppConfirmAction<T>> actions;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) SizedBox(width: 8),
          Expanded(child: _ActionButton(action: actions[i])),
        ],
      ],
    );
  }
}

class _ActionsColumn<T> extends StatelessWidget {
  const _ActionsColumn({required this.actions});

  final List<AppConfirmAction<T>> actions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) SizedBox(height: 8),
          _ActionButton(action: actions[i]),
        ],
      ],
    );
  }
}

class _ActionButton<T> extends StatelessWidget {
  const _ActionButton({required this.action});

  final AppConfirmAction<T> action;

  @override
  Widget build(BuildContext context) {
    void onPressed() => Navigator.pop(context, action.value);

    if (action.isPrimary) {
      final bg =
          action.isDestructive ? AppColors.accent : AppColors.primary;
      final fg =
          action.isDestructive ? AppColors.onImage : AppColors.onPrimary;
      return FilledButton(
        key: action.key,
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          minimumSize: const Size.fromHeight(44),
        ),
        child: Text(action.label),
      );
    }

    return TextButton(
      key: action.key,
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor:
            action.isDestructive ? AppColors.accent : AppColors.muted,
        minimumSize: const Size.fromHeight(44),
      ),
      child: Text(action.label),
    );
  }
}
