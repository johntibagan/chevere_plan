import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/cache/signed_url_cache.dart';
import '../../../core/errors/user_facing_error.dart';
import '../../../core/photos/external_photo_url.dart';
import 'moderation_models.dart';

class ModerationRepository {
  ModerationRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  String? get _uid => _client.auth.currentUser?.id;

  Future<List<SitePhoto>> listSitePhotos(String siteId) async {
    final rows = await _client
        .from('site_photos')
        .select(
          'id, site_id, storage_path, external_url, source, attribution, '
          'uploaded_by, created_at, '
          'profiles!site_photos_uploaded_by_fkey(username)',
        )
        .eq('site_id', siteId)
        .order('sort_order')
        .order('created_at');
    return (rows as List<dynamic>)
        .map((e) => SitePhoto.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// URL para mostrar: http(s) tal cual; ruta de Storage firmada. Cacheada por [storagePath].
  Future<String> signedPhotoUrl(
    String storagePath, {
    int expiresInSeconds = 3600,
  }) async {
    final cached = SignedUrlCache.instance.get(storagePath);
    if (cached != null) return cached;

    if (isExternalPhotoUrl(storagePath)) {
      final url = storagePath.trim();
      SignedUrlCache.instance.put(
        storagePath,
        url,
        ttlSeconds: expiresInSeconds,
      );
      return url;
    }

    final url = await _client.storage
        .from('site-photos')
        .createSignedUrl(storagePath, expiresInSeconds);
    SignedUrlCache.instance.put(storagePath, url, ttlSeconds: expiresInSeconds);
    return url;
  }

  /// Firma varias fotos (caché + un lote Storage). Clave = [id] de cada ítem.
  /// [storagePath] puede ser ruta interna o URL externa.
  Future<Map<String, String>> signedPhotoUrlsParallel(
    Iterable<({String id, String storagePath})> items, {
    int expiresInSeconds = 3600,
  }) async {
    final out = <String, String>{};
    final missing = <({String id, String storagePath})>[];
    for (final item in items) {
      final cached = SignedUrlCache.instance.get(item.storagePath);
      if (cached != null) {
        out[item.id] = cached;
      } else if (isExternalPhotoUrl(item.storagePath)) {
        final url = item.storagePath.trim();
        SignedUrlCache.instance.put(
          item.storagePath,
          url,
          ttlSeconds: expiresInSeconds,
        );
        out[item.id] = url;
      } else if (item.storagePath.trim().isNotEmpty) {
        missing.add(item);
      }
    }
    if (missing.isEmpty) return out;

    try {
      final paths = [for (final m in missing) m.storagePath];
      final results = await _client.storage
          .from('site-photos')
          .createSignedUrlsResult(paths, expiresInSeconds);
      final byPath = <String, String>{};
      for (final r in results) {
        if (r is SignedUrlSuccess) {
          byPath[r.path] = r.signedUrl;
          SignedUrlCache.instance.put(
            r.path,
            r.signedUrl,
            ttlSeconds: expiresInSeconds,
          );
        }
      }
      for (final m in missing) {
        final url = byPath[m.storagePath];
        if (url != null) out[m.id] = url;
      }
    } catch (_) {
      final entries = await Future.wait(
        missing.map((item) async {
          try {
            final url = await signedPhotoUrl(
              item.storagePath,
              expiresInSeconds: expiresInSeconds,
            );
            return MapEntry(item.id, url);
          } catch (_) {
            return null;
          }
        }),
      );
      for (final e in entries.whereType<MapEntry<String, String>>()) {
        out[e.key] = e.value;
      }
    }
    return out;
  }

  Future<void> deletePhoto(SitePhoto photo) async {
    final uid = _uid;
    if (uid == null) {
      throw const AppUserError('Debes iniciar sesión.');
    }
    await _client.from('site_photos').delete().eq('id', photo.id);
    if (photo.isExternalLink || isExternalPhotoUrl(photo.storagePath)) {
      return;
    }
    final path = photo.storagePath.trim();
    if (path.isEmpty) return;
    try {
      await _client.storage.from('site-photos').remove([path]);
    } catch (_) {
      // La fila ya se borró; el archivo huérfano lo puede limpiar staff/cron.
    }
  }

  Future<void> reportPhoto({required String photoId, String? reason}) async {
    final uid = _uid;
    if (uid == null) {
      throw const AppUserError('Debes iniciar sesión.');
    }
    try {
      await _client.from('content_reports').insert({
        'reporter_id': uid,
        'target_type': 'photo',
        'target_id': photoId,
        'reason': reason?.trim().isEmpty == true ? null : reason?.trim(),
        'status': 'open',
      });
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw const AppUserError('Ya reportaste esta foto.');
      }
      rethrow;
    }
  }

  Future<void> reportReview({required String reviewId, String? reason}) async {
    final uid = _uid;
    if (uid == null) {
      throw const AppUserError('Debes iniciar sesión.');
    }
    try {
      await _client.from('content_reports').insert({
        'reporter_id': uid,
        'target_type': 'review',
        'target_id': reviewId,
        'reason': reason?.trim().isEmpty == true ? null : reason?.trim(),
        'status': 'open',
      });
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw const AppUserError('Ya reportaste esta reseña.');
      }
      rethrow;
    }
  }

  Future<List<ContentReport>> listOpenReports() async {
    final rows = await _client.rpc('list_open_content_reports');
    return (rows as List<dynamic>)
        .map((e) => ContentReport.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> updateReportStatus({
    required String reportId,
    required String status,
    String? photoStoragePath,
  }) async {
    await _client.rpc(
      'resolve_content_report',
      params: {'p_report_id': reportId, 'p_status': status},
    );
    if (status == 'actioned' &&
        photoStoragePath != null &&
        photoStoragePath.trim().isNotEmpty) {
      SignedUrlCache.instance.evict(photoStoragePath);
    }
  }
}
