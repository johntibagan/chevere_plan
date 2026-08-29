import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/user_facing_error.dart';
import '../../../core/logging/app_log.dart';
import '../../saves/data/save_models.dart';
import 'plan_builder.dart';
import 'plan_hours_policy.dart';
import 'plan_models.dart';

class PlansRepository {
  PlansRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  String? get _uid => _client.auth.currentUser?.id;

  void _assertPlanOwner(Plan plan) {
    final uid = _uid;
    if (uid == null) {
      throw const AppUserError('Debes iniciar sesión.');
    }
    if (!plan.isOwnedBy(uid)) {
      throw const AppUserError('Solo puedes editar planes que creaste.');
    }
  }

  static const _planSelect =
      'id, user_id, title, location_query, start_lat, start_lng, '
      'max_budget_amount, currency_code, status, '
      'plan_stops(id, plan_id, site_id, sort_order, visited_at, '
      'estimated_price_amount, lat, lng, '
      'sites(name, city, department, google_place_id, use_exact_pin, '
      'estimated_price_amount, cover_photo_id, '
      'site_categories(categories(name_i18n)), '
      'site_photos(id, storage_path, sort_order, created_at)))';

  static const _planSelectNoCover =
      'id, user_id, title, location_query, start_lat, start_lng, '
      'max_budget_amount, currency_code, status, '
      'plan_stops(id, plan_id, site_id, sort_order, visited_at, '
      'estimated_price_amount, lat, lng, '
      'sites(name, city, department, google_place_id, use_exact_pin, '
      'estimated_price_amount, '
      'site_categories(categories(name_i18n)), '
      'site_photos(id, storage_path, sort_order, created_at)))';

  static const _planSelectLite =
      'id, user_id, title, location_query, start_lat, start_lng, '
      'max_budget_amount, currency_code, status, '
      'plan_stops(id, plan_id, site_id, sort_order, visited_at, '
      'estimated_price_amount, lat, lng, '
      'sites(name, city, department, google_place_id, use_exact_pin, '
      'estimated_price_amount, '
      'site_categories(categories(name_i18n))))';

  /// Listado liviano (cards): count de paradas sin hidratar cada stop.
  static const _planListSelect =
      'id, user_id, title, location_query, start_lat, start_lng, '
      'max_budget_amount, currency_code, status, '
      'plan_stops(id, plan_id, site_id, sort_order, '
      'sites(name, site_categories(categories(name_i18n)), '
      'cover_photo_id, '
      'site_photos(id, storage_path, sort_order, created_at)))';

  static const _planListSelectNoCover =
      'id, user_id, title, location_query, start_lat, start_lng, '
      'max_budget_amount, currency_code, status, '
      'plan_stops(id, plan_id, site_id, sort_order, '
      'sites(name, site_categories(categories(name_i18n)), '
      'site_photos(id, storage_path, sort_order, created_at)))';

  static const _planListSelectLite =
      'id, user_id, title, location_query, start_lat, start_lng, '
      'max_budget_amount, currency_code, status, '
      'plan_stops(id, plan_id, site_id, sort_order, '
      'sites(name, site_categories(categories(name_i18n))))';

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

    Future<List<dynamic>> query(String select) async {
      final rows = await _client
          .from('plans')
          .select(select)
          .eq('user_id', uid)
          .order('created_at', ascending: false)
          .range(from, to);
      return rows as List<dynamic>;
    }

    List<dynamic> rows;
    try {
      rows = await query(_planListSelect);
    } on PostgrestException catch (e) {
      AppLog.error('listMine', name: 'plans', error: e);
      try {
        rows = await query(_planListSelectNoCover);
      } on PostgrestException catch (e2) {
        AppLog.error('listMine noCover', name: 'plans', error: e2);
        rows = await query(_planListSelectLite);
      }
    }

    final out = <Plan>[];
    for (final e in rows) {
      if (e is! Map) continue;
      try {
        out.add(_planFromJson(Map<String, dynamic>.from(e)));
      } catch (err, st) {
        AppLog.error(
          'listMine row',
          name: 'plans',
          error: err,
          stackTrace: st,
        );
      }
    }
    return out;
  }

  Future<Plan> fetchById(String planId) async {
    Future<Map<String, dynamic>> one(String select) async {
      final row = await _client
          .from('plans')
          .select(select)
          .eq('id', planId)
          .single();
      return Map<String, dynamic>.from(row);
    }

    try {
      return _planFromJson(await one(_planSelect));
    } on PostgrestException catch (e) {
      AppLog.error('fetchById', name: 'plans', error: e);
      try {
        return _planFromJson(await one(_planSelectNoCover));
      } on PostgrestException catch (e2) {
        AppLog.error('fetchById noCover', name: 'plans', error: e2);
        return _planFromJson(await one(_planSelectLite));
      }
    }
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
          'status': 'draft',
        })
        .select()
        .single();
    return fetchById(row['id'] as String);
  }

  Future<Plan> createPlan({
    required String title,
    required String locationQuery,
    double? maxBudget,
    double? startLat,
    double? startLng,
    required List<PlanCandidate> orderedStops,
  }) async {
    final uid = _uid;
    if (uid == null) {
      throw const AppUserError('Debes iniciar sesión.');
    }
    final trimmedTitle = title.trim();
    if (trimmedTitle.length < 3) {
      throw const AppUserError('Escribe al menos 3 caracteres para el título.');
    }

    final planRow = await _client
        .from('plans')
        .insert({
          'user_id': uid,
          'title': trimmedTitle,
          'location_query': locationQuery.trim(),
          'start_lat': startLat,
          'start_lng': startLng,
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
    String? siteName,
    String? city,
    String? department,
    List<String> categoryNames = const [],
    String? coverStoragePath,
  }) async {
    _assertPlanOwner(await fetchById(planId));
    final existing = await _client
        .from('plan_stops')
        .select('id, site_id, sort_order')
        .eq('plan_id', planId);
    var nextOrder = 0;
    for (final raw in existing as List) {
      if (raw is! Map) continue;
      if (raw['site_id']?.toString() == siteId) {
        throw const AppUserError('Ese sitio ya está en el plan.');
      }
      final order = (raw['sort_order'] as num?)?.toInt() ?? 0;
      if (order + 1 > nextOrder) nextOrder = order + 1;
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

    final inserted = await _client.from('plan_stops').insert({
      'plan_id': planId,
      'site_id': siteId,
      'sort_order': nextOrder,
      'lat': stopLat,
      'lng': stopLng,
      'estimated_price_amount': estimatedPriceAmount,
    }).select('id').single();

    unawaited(
      _client.from('plans').update({'status': 'active'}).eq('id', planId),
    );

    return PlanStop(
      id: inserted['id'].toString(),
      planId: planId,
      siteId: siteId,
      sortOrder: nextOrder,
      siteName: (siteName == null || siteName.trim().isEmpty)
          ? 'Sitio'
          : siteName.trim(),
      city: city,
      department: department,
      lat: stopLat,
      lng: stopLng,
      estimatedPriceAmount: estimatedPriceAmount,
      categoryNames: categoryNames,
      coverStoragePath: coverStoragePath,
    );
  }

  /// Rellena lat/lng de paradas desde `sites.location` (p. ej. sitio editado después).
  Future<Plan> hydrateMissingStopCoords(String planId, {Plan? known}) async {
    var plan = known;
    final missing = plan?.stops
            .where((s) => s.lat == null || s.lng == null)
            .toList() ??
        const <PlanStop>[];
    if (plan != null && missing.isEmpty) return plan;

    plan ??= await fetchById(planId);
    final toFill = plan.stops.where((s) => s.lat == null || s.lng == null);
    if (toFill.isEmpty) return plan;

    await Future.wait(
      toFill.map((stop) async {
        try {
          final coords = await _client.rpc(
            'get_site_coords',
            params: {'p_site_id': stop.siteId},
          );
          final parsed = _parseSiteCoords(coords);
          final lat = parsed.$1;
          final lng = parsed.$2;
          if (lat == null || lng == null) return;
          await _client.from('plan_stops').update({
            'lat': lat,
            'lng': lng,
          }).eq('id', stop.id);
        } catch (_) {}
      }),
    );
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
    _assertPlanOwner(await fetchById(planId));
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

  /// Aplica en lote altas/bajas/reorden/visitado del builder (un solo viaje a red).
  Future<void> persistPlanStops({
    required String planId,
    required List<PlanStop> initialStops,
    required List<PlanStop> desiredStops,
  }) async {
    _assertPlanOwner(await fetchById(planId));

    final desiredSiteIds = desiredStops.map((s) => s.siteId).toSet();
    final initialBySite = {for (final s in initialStops) s.siteId: s};

    final deletes = <Future<void>>[];
    for (final stop in initialStops) {
      if (desiredSiteIds.contains(stop.siteId)) continue;
      deletes.add(
        _client
            .from('plan_stops')
            .delete()
            .eq('id', stop.id)
            .eq('plan_id', planId)
            .then((_) {}),
      );
    }
    if (deletes.isNotEmpty) await Future.wait(deletes);

    final insertRows = <Map<String, dynamic>>[];
    for (var i = 0; i < desiredStops.length; i++) {
      final stop = desiredStops[i];
      if (initialBySite.containsKey(stop.siteId)) continue;
      if (stop.lat == null || stop.lng == null) {
        throw const AppUserError(
          'Solo puedes agregar sitios con ubicación en el mapa.',
        );
      }
      insertRows.add({
        'plan_id': planId,
        'site_id': stop.siteId,
        'sort_order': i,
        'lat': stop.lat,
        'lng': stop.lng,
        'estimated_price_amount': stop.estimatedPriceAmount,
        if (stop.visitedAt != null)
          'visited_at': stop.visitedAt!.toUtc().toIso8601String(),
      });
    }
    if (insertRows.isNotEmpty) {
      await _client.from('plan_stops').insert(insertRows);
    }

    final updates = <Future<void>>[];
    for (var i = 0; i < desiredStops.length; i++) {
      final stop = desiredStops[i];
      final initial = initialBySite[stop.siteId];
      if (initial == null) continue;
      final patch = <String, dynamic>{};
      if (initial.sortOrder != i) patch['sort_order'] = i;
      final wasVisited = initial.visitedAt?.toUtc().toIso8601String();
      final nowVisited = stop.visitedAt?.toUtc().toIso8601String();
      if (wasVisited != nowVisited) patch['visited_at'] = nowVisited;
      if (patch.isEmpty) continue;
      updates.add(
        _client
            .from('plan_stops')
            .update(patch)
            .eq('id', initial.id)
            .eq('plan_id', planId)
            .then((_) {}),
      );
    }
    if (updates.isNotEmpty) await Future.wait(updates);

    await _client.from('plans').update({
      'status': desiredStops.isEmpty ? 'draft' : 'active',
    }).eq('id', planId);
  }

  Future<void> deletePlan(String planId) async {
    _assertPlanOwner(await fetchById(planId));
    await _client.from('plans').delete().eq('id', planId);
  }

  Future<void> updatePlanMeta({
    required String planId,
    required String title,
    required String locationQuery,
    double? maxBudget,
  }) async {
    final uid = _uid;
    if (uid == null) {
      throw const AppUserError('Debes iniciar sesión.');
    }
    final trimmed = title.trim();
    if (trimmed.length < 3) {
      throw const AppUserError('Escribe al menos 3 caracteres para el título.');
    }
    final rows = await _client
        .from('plans')
        .update({
          'title': trimmed,
          'location_query': locationQuery.trim(),
          'max_budget_amount': maxBudget,
        })
        .eq('id', planId)
        .eq('user_id', uid)
        .select('id');
    if ((rows as List).isEmpty) {
      throw const AppUserError('Solo puedes editar planes que creaste.');
    }
  }

  Future<void> reorderStops({
    required String planId,
    required List<PlanStop> ordered,
  }) async {
    _assertPlanOwner(await fetchById(planId));
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
    final stopRow = await _client
        .from('plan_stops')
        .select('plan_id')
        .eq('id', stopId)
        .maybeSingle();
    if (stopRow == null) return;
    final planId = stopRow['plan_id']?.toString();
    if (planId == null || planId.isEmpty) return;
    _assertPlanOwner(await fetchById(planId));
    await _client.from('plan_stops').update({
      'visited_at': visited ? DateTime.now().toUtc().toIso8601String() : null,
    }).eq('id', stopId);
  }

  Future<void> setStopEstimatedPrice({
    required String stopId,
    required double? amount,
  }) async {
    final stopRow = await _client
        .from('plan_stops')
        .select('plan_id')
        .eq('id', stopId)
        .maybeSingle();
    if (stopRow == null) return;
    final planId = stopRow['plan_id']?.toString();
    if (planId == null || planId.isEmpty) return;
    _assertPlanOwner(await fetchById(planId));
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
          if (raw is! Map) continue;
          try {
            final m = Map<String, dynamic>.from(raw);
            final id = m['id']?.toString();
            final planId = m['plan_id']?.toString();
            final siteId = m['site_id']?.toString();
            if (id == null ||
                id.isEmpty ||
                planId == null ||
                planId.isEmpty ||
                siteId == null ||
                siteId.isEmpty) {
              continue;
            }
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
                id: id,
                planId: planId,
                siteId: siteId,
                sortOrder: (m['sort_order'] as num?)?.toInt() ?? 0,
                siteName: (siteMap?['name'] as String?) ?? 'Sitio',
                city: siteMap?['city'] as String?,
                department: siteMap?['department'] as String?,
                googlePlaceId: siteMap?['google_place_id'] as String?,
                useExactPin: parsePgBool(siteMap?['use_exact_pin']),
                lat: (m['lat'] as num?)?.toDouble(),
                lng: (m['lng'] as num?)?.toDouble(),
                visitedAt: visited == null
                    ? null
                    : DateTime.tryParse(visited.toString()),
                estimatedPriceAmount:
                    est == null ? null : (est as num).toDouble(),
                siteEstimatedPriceAmount:
                    siteEst == null ? null : (siteEst as num).toDouble(),
                categoryNames: categoryNamesFromJoin(
                  siteMap?['site_categories'],
                ),
                coverStoragePath: siteCoverStoragePath(
                  photos: siteMap?['site_photos'],
                  coverPhotoId: siteMap?['cover_photo_id']?.toString(),
                ),
              ),
            );
          } catch (err, st) {
            AppLog.error(
              'plan stop row',
              name: 'plans',
              error: err,
              stackTrace: st,
            );
          }
        }
        stops.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      }
    }

    final budget = json['max_budget_amount'];
    final titleRaw = (json['title'] as String?)?.trim();
    return Plan(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      title: (titleRaw == null || titleRaw.isEmpty) ? 'Plan' : titleRaw,
      locationQuery: (json['location_query'] as String?) ?? '',
      startLat: (json['start_lat'] as num?)?.toDouble(),
      startLng: (json['start_lng'] as num?)?.toDouble(),
      maxBudgetAmount: budget == null ? null : (budget as num).toDouble(),
      currencyCode: (json['currency_code'] as String?) ?? 'COP',
      status: json['status'] as String? ?? 'active',
      stops: stops,
      listedStopCount: listedStopCount,
    );
  }
}
