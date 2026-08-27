/// Qué bloques de Inicio están abiertos (se recuerda en el teléfono).
class HomeSectionsOpen {
  const HomeSectionsOpen({
    this.recent = true,
    this.popular = true,
    this.quick = true,
    this.events = true,
  });

  final bool recent;
  final bool popular;
  final bool quick;
  final bool events;

  HomeSectionsOpen copyWith({
    bool? recent,
    bool? popular,
    bool? quick,
    bool? events,
  }) {
    return HomeSectionsOpen(
      recent: recent ?? this.recent,
      popular: popular ?? this.popular,
      quick: quick ?? this.quick,
      events: events ?? this.events,
    );
  }

  /// Cuatro caracteres `0`/`1`: recientes, populares, acciones, eventos.
  /// (Un 5.º bit viejo de «tarjetas» se ignora: esas viven en ☰.)
  String encode() =>
      '${recent ? '1' : '0'}'
      '${popular ? '1' : '0'}'
      '${quick ? '1' : '0'}'
      '${events ? '1' : '0'}';

  static HomeSectionsOpen decode(String? raw) {
    if (raw == null || raw.isEmpty) return const HomeSectionsOpen();
    bool bit(int i) => raw.length > i && raw[i] != '0';
    return HomeSectionsOpen(
      recent: bit(0),
      popular: raw.length > 1 ? bit(1) : true,
      quick: raw.length > 2 ? bit(2) : true,
      events: raw.length > 3 ? bit(3) : true,
    );
  }
}
