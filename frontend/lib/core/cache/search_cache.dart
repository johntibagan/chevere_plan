import 'cache_ttl.dart';
import 'entity_cache_store.dart';

/// Resultados de Explorar (SWR). Invalidar al mutar guardados o favoritos.
Future<void> invalidateSearchResultCaches(EntityCacheStore store) {
  return store.invalidatePrefix(CacheKeys.searchPrefix);
}
