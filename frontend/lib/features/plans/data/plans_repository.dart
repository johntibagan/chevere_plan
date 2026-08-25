import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/user_facing_error.dart';
import '../../saves/data/save_models.dart';
import 'plan_builder.dart';
import 'plan_hours_policy.dart';
import 'plan_models.dart';

class PlansRepository {
  PlansRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  String? get _uid => _client.auth.currentUser?.id;

  static const _planSelect =
      'id, user_id, title, location_query, start_lat, start_lng, '
      'include_public, max_budget_amount, currency_code, status, '
      'plan_stops(id, plan_id, site_id, sort_order, visited_at, '
      'estimated_price_amount, lat, lng, '
      'sites(name, city, department, google_place_id, use_exact_pin, '
      'estimated_price_amount, cover_photo_id, '
      'site_categories(categories(name_i18n)), '
      'site_photos(id, storage_path, sort_order, created_at)))';

  /// Listado liviano (cards): count de paradas sin hidratar cada stop.
  static const _planListSelect =
      'id, user_id, title, location_query, start_lat, start_lng, '
      'include_public, max_budget_amount, currency_code, status, '
      'plan_stops(id, plan_id, site_id, sort_order, '
      'sites(name, site_categories(categories(name_i18n)), '
      'cover_photo_id, '
      'site_photos(id, storage_path, sort_order, created_at)))';

  Future<List<PlanCandidate>> listCandidates({
    required String locationQuery,
    required bool includePublic,
    double? maxBudget,
  }) async {
    final rows = await _client.rpc(
      'list_plan_candidates',
      params: {
        'p_location_query': locationQuery.trim(),
        'p_include_public': includePublic,
        'p_max_budget': maxBudget,
      },
    );
    return (rows as List<dynamic>)
        .map((e) => PlanCandidate.fromJson(Map<String, dynamic>.from(e as Map)))
        .where((c) => PlanHoursPolicy.isOpenInWindow(siteId: c.siteId))
        .toList();
  }

  Future<List<Plan>> listMine({int limit = 20, int offset = 0}) async {
    final uid = _uid;
    if (uid == null) return const [];
    final from = offset < 0 ? 0 : offset;
    final to = from + (limit < 1 ? 20 : limit) - 1;
    final rows = await _client
        .from('plans')
        .select(_planListSelect)
        .eq('user_id', uid)
        .order('created_at', ascending: false)
        .range(from, to);
    return (rows as List<dynamic>)
        .map((e) => _planFromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<Plan> fetchById(String planId) async {
    final row = await _client
        .from('plans')
        .select(_planSelect)
        .eq('id', planId)
        .single();
    return _planFromJson(Map<String, dynamic>.from(row));
  }

  Future<Plan> createDraft({required String title}) async {
    final uid = _uid;
    if (uid == null) {
      throw const AppUserError('Debes iniciar sesión.');
    }
    final trimmed = title.trim();
    final row = await _client
        .from('plans')
        .insert({
          'user_id': uid,
          'title': trimmed.isEmpty ? 'Plan sin título' : trimmed,
          'location_query': '',
          'include_public': true,
          'status': 'draft',
        })
        .select()
        .single();
    return fetchById(row['id'] as String);
  }

  Future<Plan> createPlan({
    required String title,
    required String locationQuery,
    required bool includePublic,
    double? maxBudget,
    double? startLat,
    double? startLng,
    required List<PlanCandidate> orderedStops,
  }) async {
    final uid = _uid;
    if (uid == null) {
      throw const AppUserError('Debes iniciar sesión.');
    }

    final planRow = await _client
        .from('plans')
        .insert({
          'user_id': uid,
          'title': title.trim().isEmpty
              ? 'Plan en ${locationQuery.trim()}'
              : title.trim(),
          'location_query': locationQuery.trim(),
          'start_lat': startLat,
          'start_lng': startLng,
          'include_public': includePublic,
          'max_budget_amount': maxBudget,
          'status': orderedStops.isEmpty ? 'draft' : 'active',
        })
        .select()
        .single();

    final planId = planRow['id'] as String;
    if (orderedStops.isNotEmpty) {
      final stopRows = <Map<String, dynamic>>[];
      for (var i = 0; i < orderedStops.length; i++) {
        final c = orderedStops[i];
        stopRows.add({
          'plan_id': planId,
          'site_id': c.siteId,
          'sort_order': i,
          'estimated_price_amount': c.estimatedPriceAmount,
          'lat': c.lat,
          'lng': c.lng,
        });
      }
      await _client.from('plan_stops').insert(stopRows);
    }
    return fetchById(planId);
  }

  Future<PlanStop> addStop({
    required String planId,
    required String siteId,
    double? lat,
    double? lng,
    double? estimatedPriceAmount,
  }) async {
    final existing = await _client
        .from('plan_stops')
        .select('id')
        .eq('plan_id', planId)
        .eq('site_id', siteId)
        .maybeSingle();
    if (existing != null) {
      throw const AppUserError('Ese sitio ya está en el plan.');
    }

    var stopLat = lat;
    var stopLng = lng;
    if (stopLat == null || stopLng == null) {
      try {
        final coords = await _client.rpc(
          'get_site_coords',
          params: {'p_site_id': siteId},
        );
        final parsed = _parseSiteCoords(coords);
        stopLat ??= parsed.$1;
        stopLng ??= parsed.$2;
      } catch (_) {}
    }
    if (stopLat == null || stopLng == null) {
      throw const AppUserError(
        'Solo puedes agregar sitios con ubicación en el mapa.',
      );
    }

    final maxRow = await _client
        .from('plan_stops')
        .select('sort_order')
        .eq('plan_id', planId)
        .order('sort_order', ascending: false)
        .limit(1)
        .maybeSingle();
    final nextOrder = ((maxRow?['sort_order'] as num?)?.toInt() ?? -1) + 1;

    await _client.from('plan_stops').insert({
      'plan_id': planId,
      'site_id': siteId,
      'sort_order': nextOrder,
      'lat': stopLat,
      'lng': stopLng,
      'estimated_price_amount': estimatedPriceAmount,
    });

    await _client.from('plans').update({'status': 'active'}).eq('id', planId);

    final plan = await fetchById(planId);
    return plan.stops.firstWhere((s) => s.siteId == siteId);
  }

  /// Rellena lat/lng de paradas desde `sites.location` (p. ej. sitio editado después).
  Future<Plan> hydrateMissingStopCoords(String planId) async {
    final plan = await fetchById(planId);
    for (final stop in plan.stops) {
      if (stop.lat != null && stop.lng != null) continue;
      try {
        final coords = await _client.rpc(
          'get_site_coords',
          params: {'p_site_id': stop.siteId},
        );
        final parsed = _parseSiteCoords(coords);
        final lat = parsed.$1;
        final lng = parsed.$2;
        if (lat == null || lng == null) continue;
        await _client.from('plan_stops').update({
          'lat': lat,
          'lng': lng,
        }).eq('id', stop.id);
      } catch (_) {}
    }
    return fetchById(planId);
  }

  /// Normaliza la respuesta de `get_site_coords` (lista u objeto).
  static (double?, double?) _parseSiteCoords(Object? coords) {
    Map<String, dynamic>? row;
    if (coords is List && coords.isNotEmpty) {
      final first = coords.first;
      if (first is Map) {
        row = Map<String, dynamic>.from(first);
      }
    } else if (coords is Map) {
      row = Map<String, dynamic>.from(coords);
    }
    if (row == null) return (null, null);
    final lat = (row['lat'] as num?)?.toDouble();
    final lng = (row['lng'] as num?)?.toDouble();
    return (lat, lng);
  }

  Future<void> removeStop({
    required String planId,
    required String stopId,
  }) async {
    await _client
        .from('plan_stops')
        .delete()
        .eq('id', stopId)
        .eq('plan_id', planId);

    final left = await _client
        .from('plan_stops')
        .select('id')
        .eq('plan_id', planId);
    if ((left as List).isEmpty) {
      await _client.from('plans').update({'status': 'draft'}).eq('id', planId);
    }
  }

  Future<void> deletePlan(String planId) async {
    await _client.from('plans').delete().eq('id', planId);
  }

  Future<void> updatePlanMeta({
    required String planId,
    required String title,
    required String locationQuery,
    required bool includePublic,
    double? maxBudget,
  }) async {
    final trimmed = title.trim();
    await _client.from('plans').update({
      'title': trimmed.isEmpty ? 'Plan sin título' : trimmed,
      'location_query': locationQuery.trim(),
      'include_public': includePublic,
      'max_budget_amount': maxBudget,
    }).eq('id', planId);
  }

  Future<void> reorderStops({
    required String planId,
    required List<PlanStop> ordered,
  }) async {
    for (var i = 0; i < ordered.length; i++) {
      await _client
          .from('plan_stops')
          .update({'sort_order': i})
          .eq('id', ordered[i].id)
          .eq('plan_id', planId);
    }
  }

  Future<void> setVisited({
    required String stopId,
    required bool visited,
  }) async {
    await _client.from('plan_stops').update({
      'visited_at': visited ? DateTime.now().toUtc().toIso8601String() : null,
    }).eq('id', stopId);
  }

  Future<void> setStopEstimatedPrice({
    required String stopId,
    required double? amount,
  }) async {
    await _client.from('plan_stops').update({
      'estimated_price_amount': amount,
    }).eq('id', stopId);
  }

  Plan _planFromJson(Map<String, dynamic> json) {
    final stopsRaw = json['plan_stops'];
    final stops = <PlanStop>[];
    int? listedStopCount;
    if (stopsRaw is List) {
      if (stopsRaw.length == 1 &&
          stopsRaw.first is Map &&
          (stopsRaw.first as Map).containsKey('count') &&
          !(stopsRaw.first as Map).containsKey('id')) {
        listedStopCount =
            ((stopsRaw.first as Map)['count'] as num?)?.toInt() ?? 0;
      } else {
        for (final raw in stopsRaw) {
          final m = Map<String, dynamic>.from(raw as Map);
          final sites = m['sites'];
          Map<String, dynamic>? siteMap;
          if (sites is Map) {
            siteMap = Map<String, dynamic>.from(sites);
          }
          final visited = m['visited_at'];
          final est = m['estimated_price_amount'];
          final siteEst = siteMap?['estimated_price_amount'];
          stops.add(
            PlanStop(
              id: m['id'] as String,
              planId: m['plan_id'] as String,
              siteId: m['site_id'] as String,
              sortOrder: m['sort_order'] as int? ?? 0,
              siteName: (siteMap?['name'] as String?) ?? 'Sitio',
              city: siteMap?['city'] as String?,
              department: siteMap?['department'] as String?,
              googlePlaceId: siteMap?['google_place_id'] as String?,
              useExactPin: parsePgBool(siteMap?['use_exact_pin']),
              lat: (m['lat'] as num?)?.toDouble(),
              lng: (m['lng'] as num?)?.toDouble(),
              visitedAt: visited == null
                  ? null
                  : DateTime.tryParse(visited as String),
              estimatedPriceAmount:
                  est == null ? null : (est as num).toDouble(),
              siteEstimatedPriceAmount:
                  siteEst == null ? null : (siteEst as num).toDouble(),
              categoryNames: categoryNamesFromJoin(
                siteMap?['site_categories'],
              ),
              coverStoragePath: siteCoverStoragePath(
                photos: siteMap?['site_photos'],
                coverPhotoId: siteMap?['cover_photo_id'] as String?,
              ),
            ),
          );
        }
        stops.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      }
    }

    final budget = json['max_budget_amount'];
    return Plan(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      locationQuery: json['location_query'] as String,
      startLat: (json['start_lat'] as num?)?.toDouble(),
      startLng: (json['start_lng'] as num?)?.toDouble(),
      includePublic: json['include_public'] as bool? ?? false,
      maxBudgetAmount: budget == null ? null : (budget as num).toDouble(),
      currencyCode: (json['currency_code'] as String?) ?? 'COP',
      status: json['status'] as String? ?? 'active',
      stops: stops,
      listedStopCount: listedStopCount,
    );
  }
}
