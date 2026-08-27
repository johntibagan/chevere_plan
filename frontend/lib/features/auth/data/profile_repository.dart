import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/user_facing_error.dart';
import '../../proximity/domain/proximity_policies.dart';
import '../domain/username_rules.dart';
import 'profile.dart';

class ProfileRepository {
  ProfileRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const _avatarsBucket = 'avatars';

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

  Future<Profile> updatePreferredDistanceUnit(String slug) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const AppUserError('Debes iniciar sesión.');
    }
    final row = await _client
        .from('profiles')
        .update({'preferred_distance_unit': slug})
        .eq('id', userId)
        .select()
        .single();
    return Profile.fromJson(row);
  }

  Future<UsernameAvailability> checkUsernameAvailable(String raw) async {
    final normalized = UsernameRules.normalize(raw);
    final local = UsernameRules.localIssue(normalized);
    if (local != null) {
      return UsernameAvailability(
        available: false,
        normalized: normalized,
        reason: switch (local) {
          UsernameLocalIssue.empty ||
          UsernameLocalIssue.invalid =>
            'invalid',
          UsernameLocalIssue.tooShort ||
          UsernameLocalIssue.tooLong =>
            'length',
          UsernameLocalIssue.reserved => 'reserved',
        },
      );
    }
    final res = await _client.rpc(
      'username_available',
      params: {'p_username': normalized},
    );
    if (res is Map<String, dynamic>) {
      return UsernameAvailability.fromJson(res);
    }
    if (res is Map) {
      return UsernameAvailability.fromJson(Map<String, dynamic>.from(res));
    }
    return const UsernameAvailability(available: false, reason: 'invalid');
  }

  Future<List<String>> suggestUsernames(String base, {int limit = 5}) async {
    final res = await _client.rpc(
      'suggest_usernames',
      params: {
        'p_base': base,
        'p_limit': limit,
      },
    );
    if (res is List) {
      return res.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
    }
    return const [];
  }

  Future<Profile> updateMyProfile({
    String? username,
    bool? useGoogleAvatar,
    bool clearCustomAvatar = false,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const AppUserError('Debes iniciar sesión.');
    }
    final res = await _client.rpc(
      'update_my_profile',
      params: {
        'p_username': username,
        'p_use_google_avatar': useGoogleAvatar,
        'p_clear_custom_avatar': clearCustomAvatar,
      },
    );
    if (res is Map<String, dynamic>) {
      return Profile.fromJson(res);
    }
    if (res is Map) {
      return Profile.fromJson(Map<String, dynamic>.from(res));
    }
    final again = await fetchCurrent();
    if (again == null) {
      throw const AppUserError('No se pudo actualizar el perfil.');
    }
    return again;
  }

  /// Sube avatar propio al bucket público `avatars` y guarda la URL.
  Future<Profile> uploadAvatar({
    required Uint8List bytes,
    required String filename,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const AppUserError('Debes iniciar sesión.');
    }
    var ext = p.extension(filename).toLowerCase();
    if (ext.isEmpty) ext = '.jpg';
    if (ext != '.jpg' && ext != '.jpeg' && ext != '.png' && ext != '.webp') {
      ext = '.jpg';
    }
    final path = '$userId/avatar$ext';
    final contentType = switch (ext) {
      '.png' => 'image/png',
      '.webp' => 'image/webp',
      _ => 'image/jpeg',
    };
    await _client.storage.from(_avatarsBucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            contentType: contentType,
            upsert: true,
          ),
        );
    final publicUrl = _client.storage.from(_avatarsBucket).getPublicUrl(path);
    // Cache-bust: la URL pública es estable.
    final bust = '$publicUrl?v=${DateTime.now().toUtc().millisecondsSinceEpoch}';
    final row = await _client
        .from('profiles')
        .update({
          'avatar_url': bust,
          'use_google_avatar': false,
        })
        .eq('id', userId)
        .select()
        .single();
    return Profile.fromJson(row);
  }

  Future<Profile> clearCustomAvatar() async {
    return updateMyProfile(clearCustomAvatar: true);
  }
}
