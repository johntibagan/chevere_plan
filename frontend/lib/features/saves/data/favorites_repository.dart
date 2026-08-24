import 'package:supabase_flutter/supabase_flutter.dart';

class FavoritesRepository {
  FavoritesRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  String? get _uid => _client.auth.currentUser?.id;

  Future<Set<String>> listMine() async {
    final uid = _uid;
    if (uid == null) return {};
    final rows = await _client.from('site_favorites').select('site_id');
    return {
      for (final row in rows)
        if (row['site_id'] is String) row['site_id'] as String,
    };
  }

  Future<void> setFavorite(String siteId, {required bool favorite}) async {
    final uid = _uid;
    if (uid == null) return;
    if (favorite) {
      await _client.from('site_favorites').upsert({
        'user_id': uid,
        'site_id': siteId,
      });
    } else {
      await _client
          .from('site_favorites')
          .delete()
          .eq('user_id', uid)
          .eq('site_id', siteId);
    }
  }
}
