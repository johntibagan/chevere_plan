import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Atajos de Inicio → Explorar (auto-búsqueda al aplicar).
enum ExploreShortcut {
  /// Radio = preferencia de recuerdos cercanos (siempre), GPS on.
  nearMe,

  /// Solo sitios con guardado propio completo.
  mySaves,

  /// Solo sitios en favoritos del usuario.
  myFavorites,

  /// Sin categorías marcadas (= todos). Auto-busca.
  byCategory,
}

/// Intención puntual; [nonce] hace que re-lanzar el mismo atajo dispare de nuevo.
class ExploreIntent {
  const ExploreIntent(this.shortcut, {required this.nonce});

  final ExploreShortcut shortcut;
  final int nonce;
}

final exploreIntentProvider =
    NotifierProvider<ExploreIntentNotifier, ExploreIntent?>(
  ExploreIntentNotifier.new,
);

class ExploreIntentNotifier extends Notifier<ExploreIntent?> {
  int _nonce = 0;

  @override
  ExploreIntent? build() => null;

  void launch(ExploreShortcut shortcut) {
    state = ExploreIntent(shortcut, nonce: ++_nonce);
  }

  void clear() {
    state = null;
  }
}
