import 'package:flutter/material.dart';

import '../l10n/context_l10n.dart';
import 'app_confirm_dialog.dart';

/// Marca sticky: la primera interacción del usuario deja el formulario “sucio”.
///
/// No compara campos (en Guardar sitio hay demasiados). Tras [arm], cualquier
/// [markDirty] o toque bajo [DirtyInteractionScope] pide confirmación al salir.
class FormDirtyTracker extends ChangeNotifier {
  bool _armed = false;
  bool _dirty = false;
  bool _suppressed = false;

  bool get hasUnsavedChanges => _armed && _dirty && !_suppressed;

  /// Activa el tracking en el siguiente frame (tras precargar el form).
  void arm() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dirty = false;
      _armed = true;
      notifyListeners();
    });
  }

  void markDirty() {
    if (!_armed || _dirty || _suppressed) return;
    _dirty = true;
    notifyListeners();
  }

  /// p. ej. mientras guarda: no bloquear el pop del éxito.
  void setSuppressed(bool value) {
    if (_suppressed == value) return;
    _suppressed = value;
    notifyListeners();
  }
}

/// Cualquier toque/pointer en [child] marca el [tracker] como sucio.
class DirtyInteractionScope extends StatelessWidget {
  const DirtyInteractionScope({
    super.key,
    required this.tracker,
    required this.child,
  });

  final FormDirtyTracker tracker;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => tracker.markDirty(),
      child: child,
    );
  }
}

/// Diálogo: ¿descartar cambios sin guardar?
///
/// Devuelve `true` si el usuario confirma descartar.
Future<bool> confirmDiscardChanges(BuildContext context) async {
  final l10n = context.l10n;
  final ok = await showAppConfirmDialog<bool>(
    context: context,
    icon: Icons.warning_amber_rounded,
    tone: AppConfirmTone.warning,
    title: l10n.discardChangesTitle,
    body: l10n.discardChangesBody,
    actions: [
      AppConfirmAction(
        label: l10n.actionDiscard,
        value: true,
        isDestructive: true,
      ),
      AppConfirmAction(
        label: l10n.discardChangesStay,
        value: false,
        isPrimary: true,
      ),
    ],
  );
  return ok == true;
}

/// Bloquea el pop del sistema / AppBar atrás si [hasUnsavedChanges].
class DiscardChangesScope extends StatelessWidget {
  const DiscardChangesScope({
    super.key,
    required this.hasUnsavedChanges,
    required this.child,
  });

  final bool hasUnsavedChanges;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final discard = await confirmDiscardChanges(context);
        if (discard && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: child,
    );
  }
}
