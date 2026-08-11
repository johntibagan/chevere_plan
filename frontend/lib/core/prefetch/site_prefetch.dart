import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../cache/cache_ttl.dart';
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
