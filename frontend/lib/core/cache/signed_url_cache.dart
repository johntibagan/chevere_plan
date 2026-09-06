import 'entity_cache_store.dart';
import 'cache_ttl.dart';

/// Caché de URLs firmadas: memoria (LRU) + Hive (`EntityCacheStore`).
///
/// TTL de firma en Storage sigue siendo el que pida el caller (p. ej. 3600 s);
/// aquí solo se reutiliza en cliente con margen [skewSeconds].
class SignedUrlCache {
  SignedUrlCache._();
  static final SignedUrlCache instance = SignedUrlCache._();

  final Map<String, _Entry> _entries = {};

  /// Máximo de rutas distintas en memoria.
  static const maxEntries = 200;

  /// Margen antes de expirar para renovar (segundos).
  static const skewSeconds = 120;

  /// Lectura síncrona solo de memoria (widgets / hot path).
  String? get(String storagePath) {
    final e = _entries.remove(storagePath);
    if (e == null) return null;
    if (DateTime.now().isAfter(e.expiresAt)) {
      return null;
    }
    _entries[storagePath] = e;
    return e.url;
  }

  /// Memoria → Hive. Si la entrada está vencida (con margen ya aplicado al
  /// guardar), se invalida y devuelve null.
  Future<String?> getAsync(String storagePath) async {
    final mem = get(storagePath);
    if (mem != null) return mem;

    final key = CacheKeys.signedUrl(storagePath);
    try {
      final record = await EntityCacheStore.instance.read(key);
      if (record == null) return null;
      final payload = record.payload;
      if (payload is! Map) {
        await EntityCacheStore.instance.invalidate(key);
        return null;
      }
      final map = Map<String, dynamic>.from(payload);
      final url = map['url'] as String?;
      final expiresAtMs = (map['expiresAtMs'] as num?)?.toInt();
      if (url == null || url.isEmpty || expiresAtMs == null) {
        await EntityCacheStore.instance.invalidate(key);
        return null;
      }
      final expiresAt =
          DateTime.fromMillisecondsSinceEpoch(expiresAtMs, isUtc: true);
      if (DateTime.now().toUtc().isAfter(expiresAt)) {
        await EntityCacheStore.instance.invalidate(key);
        return null;
      }
      _putMemory(storagePath, url, expiresAt);
      return url;
    } catch (_) {
      return null;
    }
  }

  void put(String storagePath, String url, {required int ttlSeconds}) {
    final safeTtl = (ttlSeconds - skewSeconds).clamp(60, ttlSeconds);
    final expiresAt = DateTime.now().toUtc().add(Duration(seconds: safeTtl));
    _putMemory(storagePath, url, expiresAt);
    // Disco en background; no bloquea el caller.
    // ignore: discarded_futures
    _persist(storagePath, url, expiresAt);
  }

  void _putMemory(String storagePath, String url, DateTime expiresAt) {
    _entries.remove(storagePath);
    _entries[storagePath] = _Entry(url: url, expiresAt: expiresAt);
    _evictIfNeeded();
  }

  Future<void> _persist(
    String storagePath,
    String url,
    DateTime expiresAt,
  ) async {
    try {
      await EntityCacheStore.instance.write(
        CacheKeys.signedUrl(storagePath),
        {
          'url': url,
          'expiresAtMs': expiresAt.toUtc().millisecondsSinceEpoch,
        },
      );
    } catch (_) {}
  }

  void _evictIfNeeded() {
    while (_entries.length > maxEntries) {
      _entries.remove(_entries.keys.first);
    }
  }

  void evict(String storagePath) {
    _entries.remove(storagePath);
    // ignore: discarded_futures
    EntityCacheStore.instance.invalidate(CacheKeys.signedUrl(storagePath));
  }

  /// Memoria + Hive (prefijo de firmas). Usar al cerrar sesión.
  Future<void> clear() async {
    _entries.clear();
    try {
      await EntityCacheStore.instance.invalidatePrefix(
        CacheKeys.signedUrlPrefix,
      );
    } catch (_) {}
  }
}

class _Entry {
  _Entry({required this.url, required this.expiresAt});
  final String url;
  final DateTime expiresAt;
}
