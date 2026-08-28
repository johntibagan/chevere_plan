/// Caché en memoria de URLs firmadas de Storage (evita N× createSignedUrl).
///
/// LRU acotado para no crecer sin límite en sesiones largas.
class SignedUrlCache {
  SignedUrlCache._();
  static final SignedUrlCache instance = SignedUrlCache._();

  final Map<String, _Entry> _entries = {};

  /// Máximo de rutas distintas en memoria.
  static const maxEntries = 200;

  /// Margen antes de expirar para renovar (segundos).
  static const _skewSeconds = 120;

  String? get(String storagePath) {
    final e = _entries.remove(storagePath);
    if (e == null) return null;
    if (DateTime.now().isAfter(e.expiresAt)) {
      return null;
    }
    // Reinsertar al final = más reciente (LRU).
    _entries[storagePath] = e;
    return e.url;
  }

  void put(String storagePath, String url, {required int ttlSeconds}) {
    final safeTtl = (ttlSeconds - _skewSeconds).clamp(60, ttlSeconds);
    _entries.remove(storagePath);
    _entries[storagePath] = _Entry(
      url: url,
      expiresAt: DateTime.now().add(Duration(seconds: safeTtl)),
    );
    _evictIfNeeded();
  }

  void _evictIfNeeded() {
    while (_entries.length > maxEntries) {
      _entries.remove(_entries.keys.first);
    }
  }

  void evict(String storagePath) => _entries.remove(storagePath);

  void clear() => _entries.clear();
}

class _Entry {
  _Entry({required this.url, required this.expiresAt});
  final String url;
  final DateTime expiresAt;
}
