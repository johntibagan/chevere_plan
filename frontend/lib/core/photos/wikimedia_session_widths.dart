/// Memoria de sesión: último ancho Wikimedia que cargó bien por foto.
///
/// Clave = [baseKey] (misma `base` que §5.6 de `imagenes-red.md`: cacheKey
/// estable o URL fuente). Valor `null` = funcionó el archivo original.
///
/// Solo memoria de proceso; limpiar en [clearSessionCaches] / logout.
class WikimediaSessionWidths {
  WikimediaSessionWidths._();

  static final WikimediaSessionWidths instance = WikimediaSessionWidths._();

  /// base → ancho OK (`null` = original).
  final Map<String, int?> _okByBase = {};

  /// Identidad estable de la foto (antes de sufijos `@wN` / `@orig`).
  static String baseKey({
    required String? cacheKey,
    required String sourceUrl,
  }) {
    final c = cacheKey?.trim();
    if (c != null && c.isNotEmpty) return c;
    return sourceUrl.trim();
  }

  bool has(String base) => _okByBase.containsKey(base);

  /// Solo válido si [has] es true. `null` = original.
  int? width(String base) => _okByBase[base];

  /// Registra un intento exitoso. Conserva el ancho mayor (o original).
  void remember(String base, int? widthPx) {
    final b = base.trim();
    if (b.isEmpty) return;
    if (!_okByBase.containsKey(b)) {
      _okByBase[b] = widthPx;
      return;
    }
    final prev = _okByBase[b];
    if (prev == null) return; // ya tenemos original
    if (widthPx == null) {
      _okByBase[b] = null;
      return;
    }
    if (widthPx > prev) {
      _okByBase[b] = widthPx;
    }
  }

  /// Índice en [ladder] desde el que conviene empezar (0 si no hay memoria).
  int startAttemptIndex(String base, List<int?> ladder) {
    if (ladder.isEmpty || !has(base)) return 0;
    final known = width(base);
    final idx = ladder.indexWhere((w) => w == known);
    return idx >= 0 ? idx : 0;
  }

  void clear() => _okByBase.clear();
}
