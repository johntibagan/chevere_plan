import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../cache/app_image_cache.dart';
import '../cache/cache_ttl.dart';
import '../cache/signed_url_cache.dart';
import '../di/providers.dart';

/// Prefetch liviano de fichas de sitio (ciclo 4).
///
/// - Espera [idleDelay] sin nuevos schedules (idle del usuario).
/// - Solo en Wi‑Fi / Ethernet (evita datos móviles agresivos).
/// - Máx. [maxSites] por lote; silencioso ante errores.
class SitePrefetchCoordinator {
  SitePrefetchCoordinator(this._ref);

  final Ref _ref;

  static const idleDelay = Duration(milliseconds: 400);
  static const maxSitesPerBatch = 3;

  Timer? _idle;
  final Set<String> _inflight = {};
  final Set<String> _doneSession = {};
  final Set<String> _coverWarm = {};
  var _disposed = false;

  /// Programa prefetch de los [siteIds] visibles (toma los primeros [max]).
  void scheduleVisibleSites(
    Iterable<String> siteIds, {
    int max = maxSitesPerBatch,
  }) {
    if (_disposed) return;
    final ids = siteIds
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .take(max)
        .toList(growable: false);
    if (ids.isEmpty) return;

    _idle?.cancel();
    _idle = Timer(idleDelay, () {
      unawaited(_run(ids));
    });
  }

  /// Descarga portadas visibles al disco (mismo cacheKey que [AppNetworkImage]).
  void warmupCoverPaths(Iterable<String?> paths) {
    if (_disposed) return;
    final uniq = <String>[];
    for (final raw in paths) {
      final p = raw?.trim();
      if (p == null || p.isEmpty) continue;
      if (_coverWarm.contains(p)) continue;
      _coverWarm.add(p);
      uniq.add(p);
    }
    if (uniq.isEmpty) return;
    unawaited(_warmupCovers(uniq.take(8).toList()));
  }

  Future<void> _warmupCovers(List<String> paths) async {
    final moderation = _ref.read(moderationRepositoryProvider);
    for (final path in paths) {
      if (_disposed) return;
      try {
        final cached = SignedUrlCache.instance.get(path);
        final url = cached ?? await moderation.signedPhotoUrl(path);
        await AppImageCacheManager.instance.downloadFile(url, key: path);
      } catch (_) {}
    }
  }

  void cancelPending() {
    _idle?.cancel();
    _idle = null;
  }

  void dispose() {
    _disposed = true;
    cancelPending();
    _inflight.clear();
  }

  Future<bool> _allowOnCurrentNetwork() async {
    try {
      final results = await Connectivity().checkConnectivity();
      for (final r in results) {
        if (r == ConnectivityResult.wifi ||
            r == ConnectivityResult.ethernet) {
          return true;
        }
      }
      return false;
    } catch (_) {
      // Sin señal clara → no prefetch (conservador con datos).
      return false;
    }
  }

  Future<bool> _isFichaFresh(String siteId) async {
    try {
      final record =
          await _ref.read(entityCacheStoreProvider).read(CacheKeys.siteFicha(siteId));
      if (record == null) return false;
      final age = DateTime.now().toUtc().difference(record.fetchedAt);
      return age <= CacheTtl.siteFicha.fresh;
    } catch (_) {
      return false;
    }
  }

  Future<void> _run(List<String> ids) async {
    if (_disposed) return;
    if (!await _allowOnCurrentNetwork()) return;

    for (final id in ids) {
      if (_disposed) return;
      if (_doneSession.contains(id) || _inflight.contains(id)) continue;
      if (await _isFichaFresh(id)) {
        _doneSession.add(id);
        continue;
      }

      _inflight.add(id);
      try {
        // Dispara SWR / red vía provider; errores se ignoran.
        await _ref.read(siteFichaProvider(id).future);
        _doneSession.add(id);
      } catch (_) {
        // Prefetch no debe afectar UI ni mostrar errores técnicos.
      } finally {
        _inflight.remove(id);
      }
    }
  }
}

final sitePrefetchProvider = Provider<SitePrefetchCoordinator>((ref) {
  final coord = SitePrefetchCoordinator(ref);
  ref.onDispose(coord.dispose);
  return coord;
});
