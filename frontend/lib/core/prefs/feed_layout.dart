/// Cómo se listan sitios en Inicio (populares) y Explorar.
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

  double photoHeight({required bool showOriginRow}) => switch (this) {
        list => 80,
        grid2 => 100,
        grid3 => showOriginRow ? 64 : 72,
        grid4 => showOriginRow ? 48 : 56,
      };

  double childAspectRatio({required bool showOriginRow}) {
    if (showOriginRow) {
      return switch (this) {
        list => 1,
        grid2 => 0.88,
        grid3 => 0.58,
        grid4 => 0.46,
      };
    }
    return switch (this) {
      list => 1,
      grid2 => 1.05,
      grid3 => 0.78,
      grid4 => 0.62,
    };
  }
}
