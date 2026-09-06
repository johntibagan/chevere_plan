import 'package:supabase_flutter/supabase_flutter.dart';

import 'proximity_models.dart';

class ProximityRepository {
  ProximityRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<ProximitySite>> listTargets({
    required bool includePublic,
    int limit = 100,
    int offset = 0,
  }) async {
    final rows = await _client.rpc(
      'list_proximity_sites',
      params: {
        'p_include_public': includePublic,
        'p_limit': limit,
        'p_offset': offset,
      },
    );
    final list = (rows as List<dynamic>)
        .map((e) => ProximitySite.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    // Propios primero (Android máx. 100).
    list.sort((a, b) {
      if (a.isOwn == b.isOwn) return 0;
      return a.isOwn ? -1 : 1;
    });
    if (list.length > 100) return list.take(100).toList();
    return list;
  }
}
