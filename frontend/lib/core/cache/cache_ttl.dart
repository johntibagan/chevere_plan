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

  static const distanceUnits = CacheTtl(
    fresh: Duration(hours: 24),
    stale: Duration(days: 7),
  );

  /// DIVIPOLA: el dato más frío. Tras la 1ª sync, selector 100% local.
  static const geoCatalog = CacheTtl(
    fresh: Duration(days: 30),
    stale: Duration(days: 90),
  );

  static const mySaves = CacheTtl(
    fresh: Duration(minutes: 3),
    stale: Duration(hours: 24),
  );

  static const favorites = CacheTtl(
    fresh: Duration(minutes: 5),
    stale: Duration(hours: 24),
  );

  static const siteFicha = CacheTtl(
    fresh: Duration(minutes: 3),
    stale: Duration(hours: 12),
  );

  static const plans = CacheTtl(
    fresh: Duration(minutes: 5),
    stale: Duration(hours: 24),
  );

  static const routes = CacheTtl(
    fresh: Duration(minutes: 5),
    stale: Duration(hours: 24),
  );

  static const search = CacheTtl(
    fresh: Duration(minutes: 2),
    stale: Duration(minutes: 45),
  );
}

abstract final class CacheKeys {
  static String mySavesSummary(String uid) => 'my_saves_summary_p0:$uid';
  static String favoriteSiteIds(String uid) => 'favorite_site_ids:$uid';
  static String categories() => 'categories:v1';
  static String transportTypes() => 'transport_types:v1';
  static String distanceUnits() => 'distance_units:v1';
  static String geoCatalog() => 'geo_catalog:v1';
  static String siteFicha(String siteId) => 'site_ficha_v2:$siteId';
  static String plansPage0(String uid) => 'plans_p0:$uid';
  static String routesAll(String uid) => 'routes_all:$uid';
  static String search(String fingerprint) => 'search:$fingerprint';
  /// Prefijo para invalidar todas las búsquedas (guardar / favorito).
  static const searchPrefix = 'search:';
  static String homeNearby(String uid) => 'home_nearby_v1:$uid';
}
