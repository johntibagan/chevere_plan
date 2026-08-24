/// Qué bloques de Inicio están abiertos (se recuerda en el teléfono).
class HomeSectionsOpen {
  const HomeSectionsOpen({
    this.recent = true,
    this.popular = true,
    this.quick = true,
  });

  final bool recent;
  final bool popular;
  final bool quick;

  HomeSectionsOpen copyWith({
    bool? recent,
    bool? popular,
    bool? quick,
  }) {
    return HomeSectionsOpen(
      recent: recent ?? this.recent,
      popular: popular ?? this.popular,
      quick: quick ?? this.quick,
    );
  }

  /// Tres caracteres `0`/`1`: recientes, populares, acciones.
  String encode() =>
      '${recent ? '1' : '0'}${popular ? '1' : '0'}${quick ? '1' : '0'}';

  static HomeSectionsOpen decode(String? raw) {
    if (raw == null || raw.length < 3) return const HomeSectionsOpen();
    bool bit(int i) => raw[i] != '0';
    return HomeSectionsOpen(
      recent: bit(0),
      popular: bit(1),
      quick: bit(2),
    );
  }
}
