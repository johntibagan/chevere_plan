import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/beta_release.dart';

class BetaReleaseRepository {
  BetaReleaseRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<BetaRelease?> fetchCurrent() async {
    final row = await _client
        .from('beta_release')
        .select('version, build, apk_url')
        .eq('id', 1)
        .maybeSingle();
    if (row == null) return null;
    return BetaRelease.fromJson(Map<String, dynamic>.from(row));
  }
}
