import 'package:supabase_flutter/supabase_flutter.dart';

import 'route_models.dart';

class RoutesRepository {
  RoutesRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<RouteHistoryEntry>> listMine({
    int limit = 20,
    int offset = 0,
  }) async {
    // RPC actual no acepta limit/offset (tope fijo 200 en SQL).
    // Ventana en cliente hasta que exista list_my_route_history(p_limit, p_offset).
    final rows = await _client.rpc('list_my_route_history');
    final all = (rows as List<dynamic>)
        .map(
          (e) => RouteHistoryEntry.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
    final from = offset < 0 ? 0 : offset;
    if (from >= all.length) return const [];
    final to = (from + (limit < 1 ? 20 : limit)).clamp(0, all.length);
    return all.sublist(from, to);
  }

  /// Carga completa (máx. 200 del RPC) para SWR; la UI pagina en cliente.
  Future<List<RouteHistoryEntry>> listMineAll() async {
    final rows = await _client.rpc('list_my_route_history');
    return (rows as List<dynamic>)
        .map(
          (e) => RouteHistoryEntry.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  }
}
