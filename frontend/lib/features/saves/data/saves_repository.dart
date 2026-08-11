import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/errors/user_facing_error.dart';
import '../domain/save_policies.dart';
import 'save_models.dart';
import 'site_ficha.dart';
import 'social_link_models.dart';

class SavesRepository {
  SavesRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  final _uuid = const Uuid();

  static const _saveSelect =
      'id, user_id, site_id, status, is_public, source_url, source_network, notes, created_at, '
      'is_possible_duplicate, possible_duplicate_of_site_id, '
      'sites!user_saves_site_id_fkey(name, city, department, address_line, is_public, '
      'is_physical_place, '
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
    return SavePolicies.computeStatus(
      categoryIds: categoryIds,
      city: city,
      addressLine: addressLine,
      latitude: latitude,
      longitude: longitude,
    );
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
        'p_radius_m': SavePolicies.duplicateSearchRadiusM,
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
          ? DateTime.now().toUtc().add(SavePolicies.draftRemindAfter)
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
        ? DateTime.now().toUtc().add(SavePolicies.draftRemindAfter)
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
    if (current >= SavePolicies.maxPhotosPerSite) {
      throw AppUserError(
        'Máximo ${SavePolicies.maxPhotosPerSite} fotos por sitio.',
      );
    }

    final rawExt = file.path.split('.').last.toLowerCase();
    final ext = (rawExt == 'jpg' ||
            rawExt == 'jpeg' ||
            rawExt == 'png' ||
            rawExt == 'webp' ||
            rawExt == 'heic')
        ? rawExt
        : 'jpg';
    final objectPath = '$uid/$siteId/${_uuid.v4()}.$ext';
    final contentType = switch (ext) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'heic' => 'image/heic',
      _ => 'image/jpeg',
    };

    try {
      await _client.storage.from('site-photos').upload(
            objectPath,
            file,
            fileOptions: FileOptions(
              upsert: false,
              contentType: contentType,
            ),
          );
    } on StorageException catch (e) {
      throw AppUserError(
        e.message.isNotEmpty
            ? e.message
            : 'No se pudo subir la foto. Intenta de nuevo.',
      );
    }

    try {
      await _client.from('site_photos').insert({
        'site_id': siteId,
        'storage_path': objectPath,
        'source': 'user',
        'uploaded_by': uid,
        'sort_order': current,
      });
    } on PostgrestException catch (e) {
      try {
        await _client.storage.from('site-photos').remove([objectPath]);
      } catch (_) {}
      if (e.code == '42501' || (e.message.toLowerCase().contains('policy'))) {
        throw const AppUserError(
          'No puedes añadir fotos a este sitio (solo el creador).',
        );
      }
      throw AppUserError(
        e.message.isNotEmpty
            ? e.message
            : 'No se pudo guardar la foto. Intenta de nuevo.',
      );
    }
  }

  Future<List<UserSave>> listStaleDrafts() async {
    final uid = _uid;
    if (uid == null) return [];
    final cutoff = DateTime.now().toUtc().subtract(SavePolicies.draftRemindAfter);
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

  Future<SaveEditData> loadForEdit(String saveId) async {
    final uid = _uid;
    if (uid == null) {
      throw const AppUserError('Debes iniciar sesión.');
    }

    final row = await _client
        .from('user_saves')
        .select(_saveSelect)
        .eq('id', saveId)
        .eq('user_id', uid)
        .single();

    final save =
        UserSave.fromJoinedJson(Map<String, dynamic>.from(row as Map));

    final catRows = await _client
        .from('site_categories')
        .select('category_id')
        .eq('site_id', save.siteId);
    final categoryIds = (catRows as List)
        .map((e) => (e as Map)['category_id'] as String)
        .toList();

    double? lat;
    double? lng;
    try {
      final coords = await _client.rpc(
        'get_site_coords',
        params: {'p_site_id': save.siteId},
      );
      final parsed = _parseSiteCoords(coords);
      lat = parsed.$1;
      lng = parsed.$2;
    } catch (_) {
      // Sin coords prellenadas; ciudad/dirección bastan para editar.
    }

    return SaveEditData(
      save: save,
      categoryIds: categoryIds,
      latitude: lat,
      longitude: lng,
    );
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

  Future<UserSave> updateSave({
    required String saveId,
    required String siteId,
    required SaveDraftInput input,
  }) async {
    final uid = _uid;
    if (uid == null) {
      throw const AppUserError('Debes iniciar sesión para guardar.');
    }

    final name = input.name.trim().isEmpty ? 'Sin nombre' : input.name.trim();
    final isPublic =
        input.isPhysicalPlace ? input.isPublic : false;
    final status = computeStatus(
      categoryIds: input.categoryIds,
      city: input.city,
      addressLine: input.addressLine,
      latitude: input.latitude,
      longitude: input.longitude,
    );

    await _client.from('sites').update({
      'name': name,
      'status': status.dbValue,
      'is_public': isPublic,
      'is_physical_place': input.isPhysicalPlace,
      'address_line': input.addressLine?.trim(),
      'city': input.city?.trim(),
      'department': input.department?.trim(),
    }).eq('id', siteId);

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

    await _client.from('site_categories').delete().eq('site_id', siteId);
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
        ? DateTime.now().toUtc().add(SavePolicies.draftRemindAfter)
        : null;

    final save = await _client
        .from('user_saves')
        .update({
          'status': status.dbValue,
          'is_public': isPublic,
          'source_url': input.sourceUrl,
          'source_network': input.sourceNetwork,
          'notes': input.notes,
          'draft_remind_at': draftRemindAt?.toIso8601String(),
        })
        .eq('id', saveId)
        .eq('user_id', uid)
        .select(_saveSelect)
        .single();

    return UserSave.fromJoinedJson(Map<String, dynamic>.from(save));
  }

  /// Guardado propio ligado a un sitio, si existe.
  Future<UserSave?> findMineBySiteId(String siteId) async {
    final uid = _uid;
    if (uid == null) return null;

    final row = await _client
        .from('user_saves')
        .select(_saveSelect)
        .eq('user_id', uid)
        .eq('site_id', siteId)
        .maybeSingle();

    if (row == null) return null;
    return UserSave.fromJoinedJson(Map<String, dynamic>.from(row));
  }

  static const _siteSelect =
      'id, name, city, department, address_line, is_public, is_physical_place, '
      'site_categories(categories(name_i18n)), '
      'site_contributors(user_id, profiles(display_name))';

  /// Ficha de sitio (propia o pública visible por RLS).
  Future<SiteFicha> loadSiteFicha(String siteId) async {
    SiteFicha ficha;
    final mine = await findMineBySiteId(siteId);
    if (mine != null) {
      ficha = SiteFicha.fromSave(mine);
    } else {
      final row = await _client
          .from('sites')
          .select(_siteSelect)
          .eq('id', siteId)
          .maybeSingle();

      if (row == null) {
        throw const AppUserError('No se encontró el sitio.');
      }
      ficha = SiteFicha.fromSiteRow(Map<String, dynamic>.from(row));
    }

    try {
      final coords = await _client.rpc(
        'get_site_coords',
        params: {'p_site_id': siteId},
      );
      final parsed = _parseSiteCoords(coords);
      return ficha.copyWithMeta(lat: parsed.$1, lng: parsed.$2);
    } catch (_) {
      return ficha;
    }
  }

  Future<List<SiteSocialLink>> listSocialLinks(String siteId) async {
    final rows = await _client
        .from('site_social_links')
        .select(
          'id, site_id, url, network, title, description, image_url, sort_order',
        )
        .eq('site_id', siteId)
        .order('sort_order');
    return (rows as List)
        .map(
          (e) => SiteSocialLink.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  }

  /// Reemplaza los enlaces del sitio (creador). Mantiene unique (site_id, url).
  Future<void> replaceSocialLinks({
    required String siteId,
    required List<SocialLinkDraft> links,
  }) async {
    final uid = _uid;
    if (uid == null) throw const AppUserError('Sin sesión');

    await _client.from('site_social_links').delete().eq('site_id', siteId);
    if (links.isEmpty) return;

    final rows = <Map<String, dynamic>>[];
    for (var i = 0; i < links.length; i++) {
      final l = links[i];
      final url = l.url.trim();
      if (url.isEmpty) continue;
      rows.add({
        'site_id': siteId,
        'url': url,
        'network': l.network,
        'title': l.title,
        'description': l.description,
        'image_url': l.imageUrl,
        'sort_order': i,
        'added_by': uid,
      });
    }
    if (rows.isEmpty) return;
    await _client.from('site_social_links').upsert(
          rows,
          onConflict: 'site_id,url',
        );
  }
}
