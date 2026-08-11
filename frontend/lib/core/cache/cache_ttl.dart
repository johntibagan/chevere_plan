/// TTL por tipo de dato (ciclo 1 SWR).
class CacheTtl {
  const CacheTtl({required this.fresh, required this.stale});

  /// Mientras [fresh], se sirve caché sin red.
  final Duration fresh;

  /// Entre [fresh] y [stale], se sirve caché y se refresca en background.
  final Duration stale;

  static const categories = CacheTtl(
    fresh: Duration(hours: 24),
    stale: Duration(days: 7),
  );

  static const transportTypes = CacheTtl(
    fresh: Duration(hours: 24),
    stale: Duration(days: 7),
  );

  static const mySaves = CacheTtl(
    fresh: Duration(minutes: 3),
    stale: Duration(hours: 24),
  );

  static const siteFicha = CacheTtl(
    fresh: Duration(minutes: 3),
    stale: Duration(hours: 12),
  );
}

abstract final class CacheKeys {
  static String mySavesSummary(String uid) => 'my_saves_summary:$uid';
  static String categories() => 'categories:v1';
  static String transportTypes() => 'transport_types:v1';
  static String siteFicha(String siteId) => 'site_ficha:$siteId';
}
