import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../plans/data/plan_hours_policy.dart';
import 'search_models.dart';

class SearchRepository {
  SearchRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<SearchHit>> search(SearchFilters filters) async {
    try {
      return await _searchRpc(filters);
    } catch (e, st) {
      developer.log(
        'search_sites RPC failed — using local fallback',
        name: 'search',
        error: e,
        stackTrace: st,
      );
      if (kDebugMode) {
        debugPrint('search_sites RPC error: $e');
      }
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
        .toList();
  }

  /// Fallback sin RPC: mis guardados complete (+ públicos si se pide).
  Future<List<SearchHit>> _searchLocalFallback(SearchFilters filters) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return const [];

    final q = (filters.query ?? filters.locationQuery ?? '').trim().toLowerCase();
    final hits = <SearchHit>[];

    final ownRows = await _client
        .from('user_saves')
        .select(
          'site_id, sites!user_saves_site_id_fkey(id, name, city, department, estimated_price_amount, currency_code, is_public)',
        )
        .eq('user_id', uid)
        .eq('status', 'complete');

    for (final raw in ownRows as List<dynamic>) {
      final m = Map<String, dynamic>.from(raw as Map);
      final site = m['sites'];
      if (site is! Map) continue;
      final s = Map<String, dynamic>.from(site);
      final hit = _hitFromSite(s, isOwn: true);
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
          .limit(100);

      final ownIds = hits.map((h) => h.siteId).toSet();
      for (final raw in pubRows as List<dynamic>) {
        final s = Map<String, dynamic>.from(raw as Map);
        final id = s['id'] as String?;
        if (id == null || ownIds.contains(id)) continue;
        final hit = _hitFromSite(s, isOwn: false);
        if (_matchesText(hit, q) && _matchesBudget(hit, filters)) {
          hits.add(hit);
        }
      }
    }

    return hits;
  }

  SearchHit _hitFromSite(Map<String, dynamic> s, {required bool isOwn}) {
    final price = s['estimated_price_amount'];
    return SearchHit(
      siteId: (s['id'] as String?) ?? '',
      name: (s['name'] as String?) ?? 'Sitio',
      city: s['city'] as String?,
      department: s['department'] as String?,
      estimatedPriceAmount:
          price == null ? null : (price as num).toDouble(),
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
