import 'cache_ttl.dart';
import 'entity_cache_store.dart';

typedef JsonDecoder<T> = T Function(Object? payload);
typedef JsonEncoder<T> = Object? Function(T value);
typedef NetworkLoader<T> = Future<T> Function();

/// Read-through con stale-while-revalidate.
class SwrLoader {
  SwrLoader(this._store);

  final EntityCacheStore _store;

  /// Carga [key] respetando [ttl].
  ///
  /// - Si hay caché fresca → la devuelve.
  /// - Si hay caché stale → la devuelve y dispara [onBackgroundRefresh].
  /// - Si no hay caché (o [forceNetwork]) → red; ante fallo de red y caché
  ///   usable, devuelve caché; si no, relanza el error.
  Future<T> load<T>({
    required String key,
    required CacheTtl ttl,
    required JsonDecoder<T> decode,
    required JsonEncoder<T> encode,
    required NetworkLoader<T> network,
    bool forceNetwork = false,
    void Function(Future<T> pending)? onBackgroundRefresh,
  }) async {
    if (!forceNetwork) {
      final cached = await _store.read(key);
      if (cached != null) {
        try {
          final data = decode(cached.payload);
          final age = DateTime.now().toUtc().difference(cached.fetchedAt);
          if (age <= ttl.fresh) {
            return data;
          }
          if (age <= ttl.stale) {
            final pending = _networkAndWrite(
              key: key,
              network: network,
              encode: encode,
            );
            onBackgroundRefresh?.call(pending);
            return data;
          }
        } catch (_) {
          await _store.invalidate(key);
        }
      }
    }

    try {
      return await _networkAndWrite(
        key: key,
        network: network,
        encode: encode,
      );
    } catch (e) {
      final cached = await _store.read(key);
      if (cached != null) {
        try {
          return decode(cached.payload);
        } catch (_) {
          await _store.invalidate(key);
        }
      }
      rethrow;
    }
  }

  Future<T> _networkAndWrite<T>({
    required String key,
    required NetworkLoader<T> network,
    required JsonEncoder<T> encode,
  }) async {
    final fresh = await network();
    await _store.write(key, encode(fresh));
    return fresh;
  }
}
