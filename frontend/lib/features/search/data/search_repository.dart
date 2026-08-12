import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/logging/app_log.dart';
import '../../plans/data/plan_hours_policy.dart';
import 'search_models.dart';

/// Tope del fallback local (sin RPC). La UI pagina en cliente de 20 en 20.
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
    final params = <String, dynamic>{
      'p_include_public': filters.includePublic,
    };
    final q = filters.query?.trim();
    if (q != null && q.isNotEmpty) params['p_query'] = q;
    if (filters.categoryId != null) {
      params['p_category_id'] = filters.categoryId;
    }
    final loc = filters.locationQuery?.trim();
    if (loc != null && loc.isNotEmpty) params['p_location_query'] = loc;
    if (filters.lat != null) params['p_lat'] = filters.lat;
    if (filters.lng != null) params['p_lng'] = filters.lng;
    if (filters.radiusKm != null) params['p_radius_km'] = filters.radiusKm;
    if (filters.transportGroup != null &&
        filters.transportGroup!.isNotEmpty) {
      params['p_transport_group'] = filters.transportGroup;
    }
    if (filters.budgetMin != null) {
      params['p_budget_min'] = filters.budgetMin;
    }
    if (filters.budgetMax != null) {
      params['p_budget_max'] = filters.budgetMax;
    }

    final rows = await _client.rpc('search_sites', params: params);
    return (rows as List<dynamic>)
        .map((e) => SearchHit.fromJson(Map<String, dynamic>.from(e as Map)))
        .where((h) => PlanHoursPolicy.isOpenInWindow(siteId: h.siteId))
        .where((h) => h.lat != null && h.lng != null)
        .toList();
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
          'estimated_price_amount, currency_code, is_public)',
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
            'id, name, city, department, estimated_price_amount, currency_code, is_public',
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

    return hits;
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
      lat: lat,
      lng: lng,
      estimatedPriceAmount: price == null ? null : (price as num).toDouble(),
      currencyCode: (s['currency_code'] as String?) ?? 'COP',
      isOwn: isOwn,
    );
  }

  bool _matchesText(SearchHit hit, String q) {
    if (q.isEmpty) return true;
    final blob =
        '${hit.name} ${hit.city ?? ''} ${hit.department ?? ''}'.toLowerCase();
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
