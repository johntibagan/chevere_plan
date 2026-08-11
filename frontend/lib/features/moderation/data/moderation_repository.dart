import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/user_facing_error.dart';
import 'moderation_models.dart';

class ModerationRepository {
  ModerationRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  String? get _uid => _client.auth.currentUser?.id;

  Future<List<SitePhoto>> listSitePhotos(String siteId) async {
    final rows = await _client
        .from('site_photos')
        .select('id, site_id, storage_path')
        .eq('site_id', siteId)
        .order('sort_order');
    return (rows as List<dynamic>)
        .map((e) => SitePhoto.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  String publicPhotoUrl(String storagePath) {
    return _client.storage.from('site-photos').getPublicUrl(storagePath);
  }

  Future<void> reportPhoto({
    required String photoId,
    String? reason,
  }) async {
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

  Future<List<ContentReport>> listOpenReports() async {
    final rows = await _client.rpc('list_open_content_reports');
    return (rows as List<dynamic>)
        .map((e) => ContentReport.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> updateReportStatus({
    required String reportId,
    required String status,
  }) async {
    await _client.from('content_reports').update({
      'status': status,
    }).eq('id', reportId);
  }
}
