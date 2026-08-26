import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/logging/app_log.dart';
import '../../plans/data/plan_hours_policy.dart';
import 'search_models.dart';

/// Tope del fallback local (sin RPC). La UI pagina en cliente (`SearchPolicies.pageSize`).
const _kFallbackPublicCap = 100;

class SearchRepository {
  SearchRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<SearchHit>> search(SearchFilters filters) async {
    try {
      return await _searchRpc(filters);
    } catch (e, st) {
      AppLog.error(
        'search_sites RPC failed — using local fallback',
        name: 'search',
        error: e,
        stackTrace: st,
      );
      return _searchLocalFallback(filters);
    }
  }

  Future<List<SearchHit>> _searchRpc(SearchFilters filters) async {
    final rows = await _client.rpc(
      'search_sites',
      params: filters.toRpcParams(),
    );
    final hits = (rows as List<dynamic>)
        .map((e) => SearchHit.fromJson(Map<String, dynamic>.from(e as Map)))
        .where((h) => PlanHoursPolicy.isOpenInWindow(siteId: h.siteId))
        .where((h) => h.lat != null && h.lng != null)
        .toList();
    return _dedupeHits(hits);
  }

  /// Un resultado por sitio; si hay copia propia + público cercanos, deja uno.
  List<SearchHit> _dedupeHits(List<SearchHit> input) {
    final byId = <String, SearchHit>{};
    for (final h in input) {
      if (h.siteId.isEmpty) continue;
      final prev = byId[h.siteId];
      byId[h.siteId] = prev == null ? h : _preferHit(prev, h);
    }
    final unique = byId.values.toList();
    final kept = <SearchHit>[];
    for (final h in unique) {
      final idx = kept.indexWhere((k) => _nearDuplicate(k, h));
      if (idx < 0) {
        kept.add(h);
      } else {
        kept[idx] = _preferHit(kept[idx], h);
      }
    }
    return kept;
  }

  bool _nearDuplicate(SearchHit a, SearchHit b) {
    if (a.siteId == b.siteId) return true;
    if (!_namesSimilar(a.name, b.name)) return false;
    if (a.lat != null && a.lng != null && b.lat != null && b.lng != null) {
      // Parques grandes: hasta ~1 km
      return _approxKm(a.lat!, a.lng!, b.lat!, b.lng!) <= 1.0;
    }
    final ca = (a.city ?? '').trim().toLowerCase();
    final cb = (b.city ?? '').trim().toLowerCase();
    return ca.isNotEmpty && ca == cb;
  }

  static const _nameStop = {
    'parque',
    'acuatico',
    'acuático',
    'area',
    'área',
    'de',
    'del',
    'la',
    'el',
    'los',
    'las',
    'y',
    'e',
    'conservacion',
    'conservación',
    'centro',
  };

  String _normalizeName(String raw) {
    var s = raw.toLowerCase().trim();
    s = s.replaceAll(RegExp(r'[|,/.\-–—_()\[\]]+'), ' ');
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    // quitar tildes simples frecuentes
    const map = {
      'á': 'a',
      'é': 'e',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'ü': 'u',
      'ñ': 'n',
    };
    for (final e in map.entries) {
      s = s.replaceAll(e.key, e.value);
    }
    return s;
  }

  bool _namesSimilar(String a, String b) {
    final na = _normalizeName(a);
    final nb = _normalizeName(b);
    if (na.isEmpty || nb.isEmpty) return false;
    if (na == nb) return true;
    if (na.length >= 6 && nb.length >= 6 && (na.contains(nb) || nb.contains(na))) {
      return true;
    }
    final ta = na
        .split(' ')
        .where((t) => t.length >= 4 && !_nameStop.contains(t))
        .toSet();
    final tb = nb
        .split(' ')
        .where((t) => t.length >= 4 && !_nameStop.contains(t))
        .toSet();
    if (ta.isEmpty || tb.isEmpty) return false;
    final inter = ta.intersection(tb);
    // Token distintivo (ej. piscilago)
    if (inter.any((t) => t.length >= 6)) return true;
    return inter.length / ta.union(tb).length >= 0.45;
  }

  /// Prefiere catálogo > público; conserva isOwn.
  SearchHit _preferHit(SearchHit a, SearchHit b) {
    final SearchHit primary;
    if (a.isCatalog != b.isCatalog) {
      primary = a.isCatalog ? a : b;
    } else if (a.isPublic != b.isPublic) {
      primary = a.isPublic ? a : b;
    } else if (a.isOwn != b.isOwn) {
      primary = a.isOwn ? a : b;
    } else {
      primary = a;
    }
    return primary.copyWith(
      isOwn: a.isOwn || b.isOwn,
      isPublic: a.isPublic || b.isPublic,
      isCatalog: a.isCatalog || b.isCatalog,
      isLinked: a.isLinked || b.isLinked,
      updatedAt: () {
        final ta = a.updatedAt;
        final tb = b.updatedAt;
        if (ta == null) return tb;
        if (tb == null) return ta;
        return ta.isAfter(tb) ? ta : tb;
      }(),
    );
  }

  double _approxKm(double lat1, double lng1, double lat2, double lng2) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2) / 1000.0;
  }

  /// Fallback sin RPC: mis guardados complete (+ públicos si se pide).
  Future<List<SearchHit>> _searchLocalFallback(SearchFilters filters) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return const [];

    final q =
        (filters.query ?? filters.locationQuery ?? '').trim().toLowerCase();
    final hits = <SearchHit>[];

    final ownRows = await _client
        .from('user_saves')
        .select(
          'site_id, sites!user_saves_site_id_fkey(id, name, city, department, '
          'address_line, estimated_price_amount, currency_code, is_public, external_id)',
        )
        .eq('user_id', uid)
        .eq('status', 'complete');

    for (final raw in ownRows as List<dynamic>) {
      final m = Map<String, dynamic>.from(raw as Map);
      final site = m['sites'];
      if (site is! Map) continue;
      final s = Map<String, dynamic>.from(site);
      final siteId = s['id'] as String?;
      if (siteId == null) continue;
      final coords = await _coordsFor(siteId);
      if (coords.$1 == null || coords.$2 == null) continue;
      final hit = _hitFromSite(
        s,
        isOwn: true,
        lat: coords.$1,
        lng: coords.$2,
      );
      if (_matchesText(hit, q) && _matchesBudget(hit, filters)) {
        hits.add(hit);
      }
    }

    if (filters.includePublic) {
      final pubRows = await _client
          .from('sites')
          .select(
            'id, name, city, department, address_line, estimated_price_amount, currency_code, is_public, external_id',
          )
          .eq('is_public', true)
          .not('location', 'is', null)
          .limit(_kFallbackPublicCap);

      final ownIds = hits.map((h) => h.siteId).toSet();
      for (final raw in pubRows as List<dynamic>) {
        final s = Map<String, dynamic>.from(raw as Map);
        final id = s['id'] as String?;
        if (id == null || ownIds.contains(id)) continue;
        final coords = await _coordsFor(id);
        if (coords.$1 == null || coords.$2 == null) continue;
        final hit = _hitFromSite(
          s,
          isOwn: false,
          lat: coords.$1,
          lng: coords.$2,
        );
        if (_matchesText(hit, q) && _matchesBudget(hit, filters)) {
          hits.add(hit);
        }
      }
    }

    return _dedupeHits(hits);
  }

  Future<(double?, double?)> _coordsFor(String siteId) async {
    try {
      final coords = await _client.rpc(
        'get_site_coords',
        params: {'p_site_id': siteId},
      );
      Map<String, dynamic>? row;
      if (coords is List && coords.isNotEmpty && coords.first is Map) {
        row = Map<String, dynamic>.from(coords.first as Map);
      } else if (coords is Map) {
        row = Map<String, dynamic>.from(coords);
      }
      if (row == null) return (null, null);
      return (
        (row['lat'] as num?)?.toDouble(),
        (row['lng'] as num?)?.toDouble(),
      );
    } catch (_) {
      return (null, null);
    }
  }

  SearchHit _hitFromSite(
    Map<String, dynamic> s, {
    required bool isOwn,
    double? lat,
    double? lng,
  }) {
    final price = s['estimated_price_amount'];
    return SearchHit(
      siteId: (s['id'] as String?) ?? '',
      name: (s['name'] as String?) ?? 'Sitio',
      city: s['city'] as String?,
      department: s['department'] as String?,
      addressLine: s['address_line'] as String?,
      lat: lat,
      lng: lng,
      estimatedPriceAmount: price == null ? null : (price as num).toDouble(),
      currencyCode: (s['currency_code'] as String?) ?? 'COP',
      isOwn: isOwn,
      isPublic: s['is_public'] as bool? ?? false,
      isCatalog: (s['external_id'] as String?)?.trim().isNotEmpty == true,
    );
  }

  bool _matchesText(SearchHit hit, String q) {
    if (q.isEmpty) return true;
    final blob =
        '${hit.name} ${hit.city ?? ''} ${hit.department ?? ''} ${hit.addressLine ?? ''}'
            .toLowerCase();
    return blob.contains(q);
  }

  bool _matchesBudget(SearchHit hit, SearchFilters filters) {
    final price = hit.estimatedPriceAmount;
    if (price == null) return true;
    if (filters.budgetMin != null && price < filters.budgetMin!) return false;
    if (filters.budgetMax != null && price > filters.budgetMax!) return false;
    return true;
  }
}
