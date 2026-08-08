import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/errors/user_facing_error.dart';
import 'save_models.dart';

class SavesRepository {
  SavesRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  final _uuid = const Uuid();

  static const _saveSelect =
      'id, user_id, site_id, status, is_public, source_url, source_network, notes, created_at, '
      'is_possible_duplicate, possible_duplicate_of_site_id, '
      'sites!user_saves_site_id_fkey(name, city, department, address_line, is_public, '
      'site_categories(categories(name_i18n)), '
      'site_contributors(user_id, profiles(display_name)))';

  String? get _uid => _client.auth.currentUser?.id;

  SiteStatus computeStatus({
    required List<String> categoryIds,
    required String? city,
    required String? addressLine,
    required double? latitude,
    required double? longitude,
  }) {
    final hasCategory = categoryIds.isNotEmpty;
    final hasLocation = (city != null && city.trim().isNotEmpty) ||
        (addressLine != null && addressLine.trim().isNotEmpty) ||
        (latitude != null && longitude != null);

    if (hasCategory && hasLocation) return SiteStatus.complete;
    if (!hasCategory && !hasLocation) return SiteStatus.draft;
    if (!hasLocation) return SiteStatus.pendingLocation;
    return SiteStatus.draft;
  }

  Future<List<UserSave>> listMine() async {
    final uid = _uid;
    if (uid == null) return [];

    final rows = await _client
        .from('user_saves')
        .select(_saveSelect)
        .eq('user_id', uid)
        .order('created_at', ascending: false);

    return (rows as List)
        .map((e) => UserSave.fromJoinedJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<List<PossibleDuplicate>> findPossibleDuplicates({
    required String name,
    String? city,
    double? latitude,
    double? longitude,
  }) async {
    if (name.trim().isEmpty) return [];
    final rows = await _client.rpc(
      'find_possible_duplicate_sites',
      params: {
        'p_name': name.trim(),
        'p_lat': latitude,
        'p_lng': longitude,
        'p_city': city?.trim().isEmpty == true ? null : city?.trim(),
        'p_radius_m': 100,
      },
    );
    return (rows as List)
        .map(
          (e) => PossibleDuplicate.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  }

  Future<UserSave> createSave(SaveDraftInput input) async {
    final uid = _uid;
    if (uid == null) {
      throw const AppUserError('Debes iniciar sesión para guardar.');
    }

    final name = input.name.trim().isEmpty ? 'Sin nombre' : input.name.trim();
    final isPublic =
        input.isPhysicalPlace ? input.isPublic : false; // §3.6

    final status = computeStatus(
      categoryIds: input.categoryIds,
      city: input.city,
      addressLine: input.addressLine,
      latitude: input.latitude,
      longitude: input.longitude,
    );

    // Caso: confirmar mismo sitio público existente (§5)
    if (input.linkToExistingSiteId != null) {
      final existingId = input.linkToExistingSiteId!;
      await _client.from('site_contributors').upsert({
        'site_id': existingId,
        'user_id': uid,
      });

      final draftRemindAt = status == SiteStatus.draft
          ? DateTime.now().toUtc().add(const Duration(hours: 24))
          : null;

      final save = await _client
          .from('user_saves')
          .upsert({
            'user_id': uid,
            'site_id': existingId,
            'status': status.dbValue,
            'is_public': isPublic,
            'source_url': input.sourceUrl,
            'source_network': input.sourceNetwork,
            'notes': input.notes,
            'draft_remind_at': draftRemindAt?.toIso8601String(),
            'is_possible_duplicate': true,
            'possible_duplicate_of_site_id': existingId,
          }, onConflict: 'user_id, site_id')
          .select(_saveSelect)
          .single();

      return UserSave.fromJoinedJson(Map<String, dynamic>.from(save));
    }

    final siteInsert = <String, dynamic>{
      'name': name,
      'status': status.dbValue,
      'is_public': isPublic,
      'is_physical_place': input.isPhysicalPlace,
      'address_line': input.addressLine?.trim(),
      'city': input.city?.trim(),
      'department': input.department?.trim(),
      'created_by': uid,
    };

    final site = await _client
        .from('sites')
        .insert(siteInsert)
        .select('id')
        .single();

    final siteId = site['id'] as String;

    if (input.latitude != null && input.longitude != null) {
      await _client.rpc(
        'set_site_location',
        params: {
          'p_site_id': siteId,
          'p_lng': input.longitude,
          'p_lat': input.latitude,
        },
      );
    }

    if (input.categoryIds.isNotEmpty) {
      await _client.from('site_categories').insert(
            input.categoryIds
                .map(
                  (cid) => {
                    'site_id': siteId,
                    'category_id': cid,
                    'added_by': uid,
                  },
                )
                .toList(),
          );
    }

    if (isPublic) {
      await _client.from('site_contributors').upsert({
        'site_id': siteId,
        'user_id': uid,
      });
    }

    final draftRemindAt = status == SiteStatus.draft
        ? DateTime.now().toUtc().add(const Duration(hours: 24))
        : null;

    final save = await _client
        .from('user_saves')
        .insert({
          'user_id': uid,
          'site_id': siteId,
          'status': status.dbValue,
          'is_public': isPublic,
          'source_url': input.sourceUrl,
          'source_network': input.sourceNetwork,
          'notes': input.notes,
          'draft_remind_at': draftRemindAt?.toIso8601String(),
          'is_possible_duplicate': false,
        })
        .select(_saveSelect)
        .single();

    return UserSave.fromJoinedJson(Map<String, dynamic>.from(save));
  }

  Future<int> countPhotos(String siteId) async {
    final rows = await _client
        .from('site_photos')
        .select('id')
        .eq('site_id', siteId);
    return (rows as List).length;
  }

  Future<void> uploadPhoto({
    required String siteId,
    required File file,
  }) async {
    final uid = _uid;
    if (uid == null) throw const AppUserError('Sin sesión');

    final current = await countPhotos(siteId);
    if (current >= 15) {
      throw const AppUserError('Máximo 15 fotos por sitio.');
    }

    final ext = file.path.split('.').last.toLowerCase();
    final objectPath = '$uid/$siteId/${_uuid.v4()}.$ext';

    await _client.storage.from('site-photos').upload(
          objectPath,
          file,
          fileOptions: const FileOptions(upsert: false),
        );

    await _client.from('site_photos').insert({
      'site_id': siteId,
      'storage_path': objectPath,
      'source': 'user',
      'uploaded_by': uid,
      'sort_order': current,
    });
  }

  Future<List<UserSave>> listStaleDrafts() async {
    final uid = _uid;
    if (uid == null) return [];
    final cutoff = DateTime.now().toUtc().subtract(const Duration(hours: 24));
    final rows = await _client
        .from('user_saves')
        .select(_saveSelect)
        .eq('user_id', uid)
        .eq('status', 'draft')
        .lt('created_at', cutoff.toIso8601String());

    return (rows as List)
        .map((e) => UserSave.fromJoinedJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> discardSave(String saveId) async {
    await _client.from('user_saves').delete().eq('id', saveId);
  }
}
