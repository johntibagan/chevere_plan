/// Cómo se listan sitios en Inicio (populares) y Explorar.
///
/// El **tamaño de celda** (ratio) es el de siempre; la portada rellena el hueco
/// interno con [Expanded] + [BoxFit.cover] (no agranda la tarjeta).
enum FeedLayout {
  list,
  grid2,
  grid3,
  grid4;

  static FeedLayout fromStorage(String? raw) => switch (raw) {
        'list' => list,
        'grid3' => grid3,
        'grid4' => grid4,
        _ => grid2,
      };

  String get storageKey => name;

  bool get isList => this == list;

  int get crossAxisCount => switch (this) {
        list => 1,
        grid2 => 2,
        grid3 => 3,
        grid4 => 4,
      };

  /// Ratio ancho/alto: **más alto = card más baja**.
  double childAspectRatio() => switch (this) {
        list => 1,
        grid2 => 1.05,
        grid3 => 0.72,
        grid4 => 0.58,
      };

  /// Mismo ratio; [availableWidth] queda por si hace falta afinar en pantallas
  /// muy estrechas sin cambiar el tamaño percibido de la card.
  double childAspectRatioForWidth(
    double availableWidth, {
    double horizontalPadding = 0,
    double crossAxisSpacing = 10,
  }) {
    // Tamaño de tarjeta = el de siempre. La imagen crece *dentro* de la card.
    return childAspectRatio();
  }

  /// Compat: la portada usa [Expanded]; no fijar altura en la card.
  double photoHeight() => switch (this) {
        list => SiteCardListMetrics.thumbSize,
        grid2 => 100,
        grid3 => 64,
        grid4 => 48,
      };
}

/// Fila lista (Explorar / Inicio): altura calculada, no un número al azar.
///
/// Presupuesto (1 línea de nombre + depto + dirección + meta distancia/precio):
/// - padding vertical textos: 8 (4+4)
/// - origen (badge 16 / corazón icon 28): 28
/// - gap: 2
/// - [SiteCardPlaceTexts] 1 línea: 12×1.25 + 4 + 10×1.25 + 4 + 10×1.25 = 48
/// - meta: 12
/// Total 98 → **100** (margen 2). Miniatura = fila − 1 px arriba/abajo.
abstract final class SiteCardListMetrics {
  static const double rowHeight = 100;
  static const double thumbPad = 1;
  static const double thumbSize = rowHeight - thumbPad * 2;
}

/// Grilla 2 columnas (anti-duplicados): mismo criterio — ratio estable.
abstract final class SiteCardGridMetrics {
  static double twoColumnAspectRatio(
    double availableWidth, {
    double horizontalPadding = 32,
    double crossAxisSpacing = 12,
    double footerEstimate = 128,
    double photoHeightFactor = 1.1,
  }) {
    // Ratio fijo conocido (no agrandar la card). Image Expanded por dentro.
    return 0.75;
  }
}
