import 'package:supabase_flutter/supabase_flutter.dart';

import 'route_models.dart';

class RoutesRepository {
  RoutesRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<RouteHistoryEntry>> listMine() async {
    final rows = await _client.rpc('list_my_route_history');
    return (rows as List<dynamic>)
        .map(
          (e) => RouteHistoryEntry.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  }
}
