import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/errors/user_facing_error.dart';
import '../../../core/logging/app_log.dart';
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
      'sites!user_saves_site_id_fkey(name, city, city_id, department, department_id, address_line, is_public, '
      'is_physical_place, google_place_id, use_exact_pin, created_by, created_at, updated_at, external_id, '
      'cover_photo_id, '
      'profiles!sites_created_by_fkey(username, avatar_url, google_avatar_url, use_google_avatar), '
      'site_categories(categories(name_i18n)), '
      'site_photos(id, storage_path, sort_order, created_at), '
      'site_contributors(user_id, created_at, profiles(username, avatar_url, google_avatar_url, use_google_avatar)))';

  /// Select liviano para Inicio (cards): sin contributors, notes, address, etc.
  static const _saveSelectSummary =
      'id, user_id, site_id, status, is_public, created_at, '
      'sites!user_saves_site_id_fkey(name, city, department, address_line, '
      'is_physical_place, use_exact_pin, '
      'google_place_id, cover_photo_id, '
      'site_categories(categories(name_i18n)), '
      'site_photos(id, storage_path, sort_order, created_at))';

  /// Fotos sí (misma portada en cards); sin `cover_photo_id` si PostgREST no la ve.
  static const _saveSelectSummaryNoCover =
      'id, user_id, site_id, status, is_public, created_at, '
      'sites!user_saves_site_id_fkey(name, city, department, address_line, '
      'is_physical_place, use_exact_pin, '
      'google_place_id, '
      'site_categories(categories(name_i18n)), '
      'site_photos(id, storage_path, sort_order, created_at))';

  static const _saveSelectSummaryLite =
      'id, user_id, site_id, status, is_public, created_at, '
      'sites!user_saves_site_id_fkey(name, city, department, address_line, '
      'is_physical_place, use_exact_pin, '
      'google_place_id, '
      'site_categories(categories(name_i18n)))';

  String? get _uid => _client.auth.currentUser?.id;

  SiteStatus computeStatus(SaveDraftInput input) {
    return SavePolicies.computeStatus(
      categoryIds: input.categoryIds,
      city: input.city,
      addressLine: input.addressLine,
      latitude: input.latitude,
      longitude: input.longitude,
      categoryIsExplicit: input.categoryIsExplicit,
      isPhysicalPlace: input.isPhysicalPlace,
    );
  }

  /// Lista para Inicio: columnas mínimas. [limit]/[offset] vía PostgREST `.range`.
  Future<List<UserSave>> listMineSummary({
    int limit = 20,
    int offset = 0,
  }) async {
    final uid = _uid;
    if (uid == null) return [];

    final from = offset < 0 ? 0 : offset;
    final to = from + (limit < 1 ? 20 : limit) - 1;

    Future<List<dynamic>> query(String select) async {
      final rows = await _client
          .from('user_saves')
          .select(select)
          .eq('user_id', uid)
          .order('created_at', ascending: false)
          .range(from, to);
      return rows as List<dynamic>;
    }

    List<dynamic> rows;
    try {
      rows = await query(_saveSelectSummary);
    } on PostgrestException catch (e) {
      AppLog.error('listMineSummary', name: 'saves', error: e);
      try {
        rows = await query(_saveSelectSummaryNoCover);
      } on PostgrestException catch (e2) {
        AppLog.error('listMineSummary noCover', name: 'saves', error: e2);
        rows = await query(_saveSelectSummaryLite);
      }
    }

    final out = <UserSave>[];
    for (final e in rows) {
      if (e is! Map) continue;
      try {
        out.add(UserSave.fromJoinedJson(Map<String, dynamic>.from(e)));
      } catch (err, st) {
        AppLog.error(
          'listMineSummary row',
          name: 'saves',
          error: err,
          stackTrace: st,
        );
      }
    }
    return out;
  }

  Future<List<PossibleDuplicate>> findPossibleDuplicates({
    required String name,
    String? city,
    double? latitude,
    double? longitude,
    String? excludeSiteId,
    String? googlePlaceId,
    int? radiusM,
  }) async {
    final n = name.trim();
    final pid = googlePlaceId?.trim();
    if (n.isEmpty &&
        (latitude == null || longitude == null) &&
        (pid == null || pid.isEmpty)) {
      return [];
    }
    final radius = SavePolicies.clampDuplicateSearchRadiusM(
      radiusM ?? SavePolicies.defaultDuplicateSearchRadiusM,
    );
    final rows = await _client.rpc(
      'find_possible_duplicate_sites',
      params: {
        'p_name': n,
        'p_lat': latitude,
        'p_lng': longitude,
        'p_city': city?.trim().isEmpty == true ? null : city?.trim(),
        'p_radius_m': radius,
        'p_exclude_site_id': excludeSiteId,
        'p_google_place_id': (pid == null || pid.isEmpty) ? null : pid,
      },
    );
    final out = <PossibleDuplicate>[];
    for (final e in rows as List) {
      if (e is! Map) continue;
      try {
        final d = PossibleDuplicate.fromJson(Map<String, dynamic>.from(e));
        if (d.siteId.isEmpty) continue;
        out.add(d);
      } catch (err, st) {
        AppLog.error(
          'findPossibleDuplicates row',
          name: 'saves',
          error: err,
          stackTrace: st,
        );
      }
    }
    return out;
  }

  /// Bloqueos al pasar un sitio público → privado.
  Future<SitePrivacyBlockers> loadPrivacyBlockers(String siteId) async {
    final raw = await _client.rpc(
      'site_privacy_blockers',
      params: {'p_site_id': siteId},
    );
    final map = raw is Map
        ? Map<String, dynamic>.from(raw)
        : Map<String, dynamic>.from(raw as Map);
    return SitePrivacyBlockers.fromJson(map);
  }

  /// Vincula mi guardado a un sitio público existente (anti-dupe).
  Future<UserSave> linkSaveToExistingSite({
    required String saveId,
    required String existingSiteId,
    required SaveDraftInput input,
  }) async {
    final uid = _uid;
    if (uid == null) {
      throw const AppUserError('Debes iniciar sesión para guardar.');
    }

    await _client.rpc(
      'link_save_to_existing_site',
      params: {
        'p_save_id': saveId,
        'p_existing_site_id': existingSiteId,
      },
    );

    await _client
        .from('user_saves')
        .update({
          'status': 'complete',
          'is_public': true,
          'source_url': input.sourceUrl,
          'source_network': input.sourceNetwork,
          'notes': input.notes,
          'draft_remind_at': null,
        })
        .eq('id', saveId)
        .eq('user_id', uid);

    return _readUserSave(saveId);
  }

  /// Crea o actualiza mi guardado apuntando a un sitio público existente.
  Future<UserSave> attachSaveToExistingSite({
    required String existingSiteId,
    String? sourceUrl,
    String? sourceNetwork,
    String? notes,
  }) async {
    if (_uid == null) {
      throw const AppUserError('Debes iniciar sesión para guardar.');
    }

    try {
      final raw = await _client.rpc(
        'attach_save_to_existing_site',
        params: {
          'p_existing_site_id': existingSiteId,
          'p_source_url': sourceUrl,
          'p_source_network': sourceNetwork,
          'p_notes': notes,
        },
      );
      final saveId = raw?.toString();
      if (saveId == null || saveId.isEmpty) {
        throw const AppUserError('No se pudo vincular al sitio existente.');
      }

      return _readUserSave(saveId);
    } on PostgrestException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('existing site must be public')) {
        throw const AppUserError(
          'Solo puedes vincular a un sitio público del catálogo.',
        );
      }
      if (msg.contains('not authenticated')) {
        throw const AppUserError('Debes iniciar sesión para guardar.');
      }
      rethrow;
    }
  }

  Future<UserSave> createSave(SaveDraftInput input) async {
    final uid = _uid;
    if (uid == null) {
      throw const AppUserError('Debes iniciar sesión para guardar.');
    }

    final name = input.name.trim().isEmpty ? 'Sin nombre' : input.name.trim();
    final located = SavePolicies.hasLocation(
      city: input.city,
      addressLine: input.addressLine,
      latitude: input.latitude,
      longitude: input.longitude,
    );
    // Público solo con lugar físico + ubicación (§3.5 / §3.6).
    final isPublic =
        input.isPhysicalPlace && input.isPublic && located;

    final status = computeStatus(input);

    // Caso: vincular a sitio público existente (cero duplicados).
    if (input.linkToExistingSiteId != null) {
      return attachSaveToExistingSite(
        existingSiteId: input.linkToExistingSiteId!,
        sourceUrl: input.sourceUrl,
        sourceNetwork: input.sourceNetwork,
        notes: input.notes,
      );
    }

    final siteInsert = <String, dynamic>{
      'name': name,
      'status': status.dbValue,
      'is_public': isPublic,
      'is_physical_place': input.isPhysicalPlace,
      'address_line': input.addressLine?.trim(),
      'city': input.city?.trim(),
      'city_id': input.cityId,
      'department': input.department?.trim(),
      'department_id': input.departmentId,
      'created_by': uid,
      'google_place_id': input.googlePlaceId,
      'use_exact_pin': input.useExactPin,
    };

    final site = await _client
        .from('sites')
        .insert(siteInsert)
        .select('id')
        .single();

    final siteId = site['id'] as String;

    await _syncSiteLocation(siteId: siteId, input: input);

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
      await _ensureSiteContributor(siteId: siteId, uid: uid);
    }

    final draftRemindAt = status != SiteStatus.complete
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
        .select('id')
        .single();

    final saveId = save['id'] as String;
    try {
      return await _readUserSave(saveId);
    } catch (e, st) {
      AppLog.error(
        'createSave read after insert',
        name: 'saves',
        error: e,
        stackTrace: st,
      );
      return UserSave(
        id: saveId,
        userId: uid,
        siteId: siteId,
        status: status,
        isPublic: isPublic,
        siteName: name,
        sourceUrl: input.sourceUrl,
        sourceNetwork: input.sourceNetwork,
        notes: input.notes,
        city: input.city,
        cityId: input.cityId,
        department: input.department,
        departmentId: input.departmentId,
        addressLine: input.addressLine,
        isPhysicalPlace: input.isPhysicalPlace,
        googlePlaceId: input.googlePlaceId,
        useExactPin: input.useExactPin,
      );
    }
  }

  /// Join gordo (portada/fotos) puede fallar si PostgREST no ve columnas nuevas.
  Future<UserSave> _readUserSave(String saveId) async {
    Future<UserSave> one(String select) async {
      final row = await _client
          .from('user_saves')
          .select(select)
          .eq('id', saveId)
          .single();
      return UserSave.fromJoinedJson(Map<String, dynamic>.from(row));
    }

    try {
      return await one(_saveSelect);
    } catch (e, st) {
      AppLog.error('readUserSave full', name: 'saves', error: e, stackTrace: st);
      try {
        return await one(_saveSelectSummary);
      } catch (e2, st2) {
        AppLog.error(
          'readUserSave summary',
          name: 'saves',
          error: e2,
          stackTrace: st2,
        );
        try {
          return await one(_saveSelectSummaryNoCover);
        } catch (e3, st3) {
          AppLog.error(
            'readUserSave noCover',
            name: 'saves',
            error: e3,
            stackTrace: st3,
          );
          return one(_saveSelectSummaryLite);
        }
      }
    }
  }

  Future<int> countPhotos(String siteId) async {
    final rows = await _client
        .from('site_photos')
        .select('id')
        .eq('site_id', siteId);
    return (rows as List).length;
  }

  Future<String?> signedPhotoUrl(String storagePath) async {
    final p = storagePath.trim();
    if (p.isEmpty) return null;
    try {
      return await _client.storage.from('site-photos').createSignedUrl(p, 3600);
    } catch (_) {
      return null;
    }
  }

  Future<void> uploadPhoto({
    required String siteId,
    required File file,
    int? knownCount,
  }) async {
    late final Uint8List bytes;
    try {
      if (!await file.exists()) {
        throw const AppUserError(
          'No se encontró el archivo de la foto. Volvé a elegirla.',
        );
      }
      bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        throw const AppUserError(
          'La foto está vacía. Volvé a elegirla.',
        );
      }
    } on AppUserError {
      rethrow;
    } catch (_) {
      throw const AppUserError(
        'No se pudo leer la foto. Volvé a elegirla.',
      );
    }

    final rawExt = p.extension(file.path).replaceFirst('.', '').toLowerCase();
    await uploadPhotoBytes(
      siteId: siteId,
      bytes: bytes,
      fileExtension: rawExt,
      knownCount: knownCount,
    );
  }

  /// Sube bytes ya en memoria (evita depender de archivos temp del picker).
  Future<void> uploadPhotoBytes({
    required String siteId,
    required Uint8List bytes,
    String fileExtension = 'jpg',
    int? knownCount,
  }) async {
    final uid = _uid;
    if (uid == null) throw const AppUserError('Sin sesión');

    if (bytes.isEmpty) {
      throw const AppUserError(
        'La foto está vacía. Volvé a elegirla.',
      );
    }

    final current = knownCount ?? await countPhotos(siteId);
    if (current >= SavePolicies.maxPhotosPerSite) {
      throw AppUserError(
        'Máximo ${SavePolicies.maxPhotosPerSite} fotos por sitio.',
      );
    }

    final rawExt = fileExtension.replaceFirst('.', '').toLowerCase();
    final ext = (rawExt == 'jpg' ||
            rawExt == 'jpeg' ||
            rawExt == 'png' ||
            rawExt == 'webp' ||
            rawExt == 'heic')
        ? (rawExt == 'jpeg' ? 'jpg' : rawExt)
        : 'jpg';
    final objectPath = '$uid/$siteId/${_uuid.v4()}.$ext';
    final contentType = switch (ext) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'heic' => 'image/heic',
      _ => 'image/jpeg',
    };

    try {
      await _client.storage.from('site-photos').uploadBinary(
            objectPath,
            bytes,
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
    } catch (e, st) {
      AppLog.error(
        'uploadPhotoBytes storage',
        name: 'saves',
        error: e,
        stackTrace: st,
      );
      throw const AppUserError(
        'No se pudo subir la foto. Intenta de nuevo.',
      );
    }

    try {
      final inserted = await _client.from('site_photos').insert({
        'site_id': siteId,
        'storage_path': objectPath,
        'source': 'user',
        'uploaded_by': uid,
        'sort_order': current,
      }).select('id').single();
      // Primera foto = portada hasta que elijan otra en el visor.
      if (current == 0) {
        final photoId = inserted['id']?.toString();
        if (photoId != null && photoId.isNotEmpty) {
          try {
            await setSiteCoverPhoto(siteId: siteId, photoId: photoId);
          } catch (_) {}
        }
      }
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

  Future<void> setSiteCoverPhoto({
    required String siteId,
    required String photoId,
  }) async {
    try {
      final updated = await _client
          .from('sites')
          .update({'cover_photo_id': photoId})
          .eq('id', siteId)
          .select('cover_photo_id');
      if (updated.isEmpty) {
        throw const AppUserError(
          'Solo el creador puede cambiar la portada del sitio.',
        );
      }
    } on PostgrestException catch (e) {
      if (e.code == '42501' || e.message.toLowerCase().contains('policy')) {
        throw const AppUserError(
          'Solo el creador puede cambiar la portada del sitio.',
        );
      }
      throw const AppUserError('Error en la app. Intenta de nuevo.');
    }
  }

  Future<void> discardSave(String saveId) async {
    await _client.from('user_saves').delete().eq('id', saveId);
  }

  Future<SaveEditData> loadForEdit(String saveId) async {
    final uid = _uid;
    if (uid == null) {
      throw const AppUserError('Debes iniciar sesión.');
    }

    final save = await _readUserSave(saveId);
    if (save.userId != uid) {
      throw const AppUserError('Debes iniciar sesión.');
    }

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

  /// Precarga para que admin/root editen un sitio del catálogo (sin guardado propio).
  Future<SiteEditData> loadSiteForStaffEdit(String siteId) async {
    final row = await _client
        .from('sites')
        .select(
          'id, name, city, city_id, department, department_id, address_line, '
          'is_public, is_physical_place, google_place_id, use_exact_pin',
        )
        .eq('id', siteId)
        .maybeSingle();

    if (row == null) {
      throw const AppUserError('No se encontró el sitio.');
    }

    final catRows = await _client
        .from('site_categories')
        .select('category_id')
        .eq('site_id', siteId);
    final categoryIds = (catRows as List)
        .map((e) => (e as Map)['category_id'] as String)
        .toList();

    double? lat;
    double? lng;
    try {
      final coords = await _client.rpc(
        'get_site_coords',
        params: {'p_site_id': siteId},
      );
      final parsed = _parseSiteCoords(coords);
      lat = parsed.$1;
      lng = parsed.$2;
    } catch (_) {}

    final m = Map<String, dynamic>.from(row);
    return SiteEditData(
      siteId: m['id'] as String,
      name: (m['name'] as String?) ?? 'Sitio',
      city: m['city'] as String?,
      cityId: m['city_id'] as String?,
      department: m['department'] as String?,
      departmentId: m['department_id'] as String?,
      addressLine: m['address_line'] as String?,
      isPublic: m['is_public'] as bool? ?? true,
      isPhysicalPlace: parsePgBool(m['is_physical_place'], orElse: true),
      googlePlaceId: m['google_place_id'] as String?,
      useExactPin: parsePgBool(m['use_exact_pin']),
      categoryIds: categoryIds,
      latitude: lat,
      longitude: lng,
    );
  }

  /// Actualiza solo el sitio (creador o admin/root). No toca `user_saves`.
  Future<void> updateSiteWithoutSave({
    required String siteId,
    required SaveDraftInput input,
  }) async {
    final uid = _uid;
    if (uid == null) {
      throw const AppUserError('Debes iniciar sesión para guardar.');
    }

    final name = input.name.trim().isEmpty ? 'Sin nombre' : input.name.trim();
    final located = SavePolicies.hasLocation(
      city: input.city,
      addressLine: input.addressLine,
      latitude: input.latitude,
      longitude: input.longitude,
    );
    final isPublic =
        input.isPhysicalPlace && input.isPublic && located;
    final status = computeStatus(input);

    if (!isPublic) {
      await _assertCanMakePrivate(siteId);
    }

    await _client.from('sites').update({
      'name': name,
      'status': status.dbValue,
      'is_public': isPublic,
      'is_physical_place': input.isPhysicalPlace,
      'address_line': input.addressLine?.trim(),
      'city': input.city?.trim(),
      'city_id': input.cityId,
      'department': input.department?.trim(),
      'department_id': input.departmentId,
      'google_place_id': input.googlePlaceId,
      'use_exact_pin': input.useExactPin,
    }).eq('id', siteId);

    await _syncSiteLocation(siteId: siteId, input: input);

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
      await _ensureSiteContributor(siteId: siteId, uid: uid);
    }
  }

  Future<void> _assertCanMakePrivate(String siteId) async {
    final blockers = await loadPrivacyBlockers(siteId);
    if (blockers.blocked) {
      throw PrivacyBlockException(blockers);
    }
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
    final located = SavePolicies.hasLocation(
      city: input.city,
      addressLine: input.addressLine,
      latitude: input.latitude,
      longitude: input.longitude,
    );
    final isPublic =
        input.isPhysicalPlace && input.isPublic && located;
    final status = computeStatus(input);

    if (!isPublic) {
      await _assertCanMakePrivate(siteId);
    }

    await _client.from('sites').update({
      'name': name,
      'status': status.dbValue,
      'is_public': isPublic,
      'is_physical_place': input.isPhysicalPlace,
      'address_line': input.addressLine?.trim(),
      'city': input.city?.trim(),
      'city_id': input.cityId,
      'department': input.department?.trim(),
      'department_id': input.departmentId,
      'google_place_id': input.googlePlaceId,
      'use_exact_pin': input.useExactPin,
    }).eq('id', siteId);

    await _syncSiteLocation(siteId: siteId, input: input);

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
      await _ensureSiteContributor(siteId: siteId, uid: uid);
    }

    final draftRemindAt = status != SiteStatus.complete
        ? DateTime.now().toUtc().add(SavePolicies.draftRemindAfter)
        : null;

    await _client
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
        .eq('user_id', uid);

    try {
      return await _readUserSave(saveId);
    } catch (e, st) {
      AppLog.error(
        'updateSave read after update',
        name: 'saves',
        error: e,
        stackTrace: st,
      );
      return UserSave(
        id: saveId,
        userId: uid,
        siteId: siteId,
        status: status,
        isPublic: isPublic,
        siteName: name,
        sourceUrl: input.sourceUrl,
        sourceNetwork: input.sourceNetwork,
        notes: input.notes,
        city: input.city,
        cityId: input.cityId,
        department: input.department,
        departmentId: input.departmentId,
        addressLine: input.addressLine,
        isPhysicalPlace: input.isPhysicalPlace,
        googlePlaceId: input.googlePlaceId,
        useExactPin: input.useExactPin,
      );
    }
  }

  /// Guardado propio ligado a un sitio, si existe.
  Future<UserSave?> findMineBySiteId(String siteId) async {
    final uid = _uid;
    if (uid == null) return null;

    Future<Map<String, dynamic>?> query(String select) async {
      final row = await _client
          .from('user_saves')
          .select(select)
          .eq('user_id', uid)
          .eq('site_id', siteId)
          .maybeSingle();
      if (row == null) return null;
      return Map<String, dynamic>.from(row);
    }

    try {
      final row = await query(_saveSelect);
      if (row == null) return null;
      return UserSave.fromJoinedJson(row);
    } catch (e, st) {
      AppLog.error('findMineBySiteId', name: 'saves', error: e, stackTrace: st);
      try {
        final row = await query(_saveSelectSummary);
        if (row == null) return null;
        return UserSave.fromJoinedJson(row);
      } catch (e2, st2) {
        AppLog.error(
          'findMineBySiteId summary',
          name: 'saves',
          error: e2,
          stackTrace: st2,
        );
        try {
          final row = await query(_saveSelectSummaryNoCover);
          if (row == null) return null;
          return UserSave.fromJoinedJson(row);
        } catch (e3, st3) {
          AppLog.error(
            'findMineBySiteId lite',
            name: 'saves',
            error: e3,
            stackTrace: st3,
          );
          final row = await query(_saveSelectSummaryLite);
          if (row == null) return null;
          return UserSave.fromJoinedJson(row);
        }
      }
    }
  }

  static const _siteSelect =
      'id, name, city, department, address_line, is_public, is_physical_place, '
      'google_place_id, use_exact_pin, created_by, created_at, updated_at, external_id, '
      'cover_photo_id, '
      'profiles!sites_created_by_fkey(username, avatar_url, google_avatar_url, use_google_avatar), '
      'site_categories(categories(name_i18n)), '
      'site_contributors(user_id, created_at, profiles(username, avatar_url, google_avatar_url, use_google_avatar))';

  static const _siteSelectLite =
      'id, name, city, department, address_line, is_public, is_physical_place, '
      'google_place_id, use_exact_pin, created_by, created_at, updated_at, external_id, '
      'profiles!sites_created_by_fkey(username, avatar_url, google_avatar_url, use_google_avatar), '
      'site_categories(categories(name_i18n)), '
      'site_contributors(user_id, created_at, profiles(username, avatar_url, google_avatar_url, use_google_avatar))';

  /// Ficha de sitio (propia o pública visible por RLS).
  Future<SiteFicha> loadSiteFicha(String siteId) async {
    Map<String, dynamic>? row;
    try {
      final raw = await _client
          .from('sites')
          .select(_siteSelect)
          .eq('id', siteId)
          .maybeSingle();
      if (raw != null) row = Map<String, dynamic>.from(raw);
    } catch (e, st) {
      AppLog.error(
        'loadSiteFicha select',
        name: 'saves',
        error: e,
        stackTrace: st,
      );
    }
    if (row == null) {
      final raw = await _client
          .from('sites')
          .select(_siteSelectLite)
          .eq('id', siteId)
          .maybeSingle();
      if (raw != null) row = Map<String, dynamic>.from(raw);
    }

    if (row == null) {
      throw const AppUserError('No se encontró el sitio.');
    }
    final siteMap = row;
    final fromSite = SiteFicha.fromSiteRow(siteMap);

    UserSave? mine;
    try {
      mine = await findMineBySiteId(siteId);
    } catch (e, st) {
      AppLog.error(
        'loadSiteFicha mine',
        name: 'saves',
        error: e,
        stackTrace: st,
      );
    }
    var ficha = mine != null
        ? SiteFicha.fromSave(mine).copyWithMeta(
            googlePlaceId: fromSite.googlePlaceId,
            useExactPin: fromSite.useExactPin,
          )
        : fromSite;

    try {
      final coords = await _client.rpc(
        'get_site_coords',
        params: {'p_site_id': siteId},
      );
      final parsed = _parseSiteCoords(coords);
      return ficha.copyWithMeta(
        lat: parsed.$1,
        lng: parsed.$2,
        googlePlaceId: fromSite.googlePlaceId,
        useExactPin: fromSite.useExactPin,
      );
    } catch (_) {
      return ficha.copyWithMeta(
        googlePlaceId: fromSite.googlePlaceId,
        useExactPin: fromSite.useExactPin,
      );
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

  /// Asegura fila en site_contributors sin tumbar el guardado.
  /// Upsert “normal” hace UPDATE si ya existe; sin política UPDATE fallaba RLS.
  Future<void> _ensureSiteContributor({
    required String siteId,
    required String uid,
  }) async {
    try {
      await _client.from('site_contributors').upsert(
        {
          'site_id': siteId,
          'user_id': uid,
        },
        onConflict: 'site_id,user_id',
        ignoreDuplicates: true,
      );
    } catch (e, st) {
      AppLog.error(
        'ensureSiteContributor',
        name: 'saves',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<void> _syncSiteLocation({
    required String siteId,
    required SaveDraftInput input,
  }) async {
    if (input.latitude != null && input.longitude != null) {
      await _client.rpc(
        'set_site_location',
        params: {
          'p_site_id': siteId,
          'p_lng': input.longitude,
          'p_lat': input.latitude,
        },
      );
      // Puede haber paradas en planes de otros; RLS no debe tumbar el guardado.
      try {
        await _client.from('plan_stops').update({
          'lat': input.latitude,
          'lng': input.longitude,
        }).eq('site_id', siteId);
      } catch (e, st) {
        AppLog.error(
          'syncSiteLocation plan_stops',
          name: 'saves',
          error: e,
          stackTrace: st,
        );
      }
      return;
    }
    if (input.clearLocation) {
      await _client.rpc(
        'clear_site_location',
        params: {'p_site_id': siteId},
      );
    }
  }
}
