/// Caché en memoria de URLs firmadas de Storage (evita N× createSignedUrl).
class SignedUrlCache {
  SignedUrlCache._();
  static final SignedUrlCache instance = SignedUrlCache._();

  final Map<String, _Entry> _entries = {};

  /// Margen antes de expirar para renovar (segundos).
  static const _skewSeconds = 120;

  String? get(String storagePath) {
    final e = _entries[storagePath];
    if (e == null) return null;
    if (DateTime.now().isAfter(e.expiresAt)) {
      _entries.remove(storagePath);
      return null;
    }
    return e.url;
  }

  void put(String storagePath, String url, {required int ttlSeconds}) {
    final safeTtl = (ttlSeconds - _skewSeconds).clamp(60, ttlSeconds);
    _entries[storagePath] = _Entry(
      url: url,
      expiresAt: DateTime.now().add(Duration(seconds: safeTtl)),
    );
  }

  void clear() => _entries.clear();
}

class _Entry {
  _Entry({required this.url, required this.expiresAt});
  final String url;
  final DateTime expiresAt;
}
