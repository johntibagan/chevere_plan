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
/// - padding vertical textos: [textBlockPadV]×2
/// - origen (badge 16 / corazón icon 24): [originRowHeight]
/// - gap: [textGap]
/// - [SiteCardPlaceTexts] 1 línea nombre + depto + dirección ≈ 48
/// - meta: [metaRowHeight]
/// Total ~102 → **104** (margen). Miniatura = fila − 1 px arriba/abajo.
///
/// **Prohibido** superar este presupuesto sin subir [rowHeight]: en debug Flutter
/// pinta la franja amarilla/negra «BOTTOM OVERFLOWED». El exceso de texto de
/// lugar va en scroll interno (`SiteCardScrollablePlaceTexts`), no fuera de la fila.
abstract final class SiteCardListMetrics {
  static const double rowHeight = 104;
  static const double thumbPad = 1;
  static const double thumbSize = rowHeight - thumbPad * 2;
  /// Icono visibilidad (~16) + tags; corazón icono encaja en 24.
  static const double originRowHeight = 24;
  static const double metaRowHeight = 14;
  static const double textGap = 1;
  /// Padding vertical del bloque de textos (lista / grilla).
  static const double textBlockPadV = 2;
}

/// Grilla (Inicio / Explorar / anti-dupe): portada vs textos en la celda.
abstract final class SiteCardGridMetrics {
  /// Portada / ilustración ≈ **55%** de la altura útil de la card.
  static const int coverFlex = 11;
  /// Origen + lugar + meta ≈ **45%**.
  static const int textFlex = 9;
  static const double coverHeightFraction = 0.55;
  static const double textHeightFraction = 0.45;

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
