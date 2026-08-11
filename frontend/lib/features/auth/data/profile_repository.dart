import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/user_facing_error.dart';
import '../../proximity/domain/proximity_policies.dart';
import 'profile.dart';

class ProfileRepository {
  ProfileRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<Profile?> fetchCurrent() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final row = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (row == null) return null;
    return Profile.fromJson(row);
  }

  Future<Profile> updateProximityPrefs({
    required int proximityRadiusM,
    required bool remindPublicSites,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const AppUserError('Debes iniciar sesión.');
    }

    final clamped = ProximityPolicies.clampRadiusM(proximityRadiusM);
    final row = await _client
        .from('profiles')
        .update({
          'proximity_radius_m': clamped,
          'remind_public_sites': remindPublicSites,
        })
        .eq('id', userId)
        .select()
        .single();

    return Profile.fromJson(row);
  }
}
