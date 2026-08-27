import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/errors/user_facing_error.dart';
import 'site_review_models.dart';

class SiteReviewsRepository {
  SiteReviewsRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  final _uuid = const Uuid();

  static const maxPhotosPerReview = 3;

  static const _reviewSelect =
      'id, site_id, user_id, body, rating, is_public, created_at, updated_at, '
      'profiles!site_reviews_user_id_fkey(username, avatar_url, google_avatar_url, use_google_avatar), '
      'site_review_photos(id, storage_path, sort_order, created_at)';

  String? get _uid => _client.auth.currentUser?.id;

  Future<SiteRatingSummary> ratingSummary(String siteId) async {
    try {
      final raw = await _client.rpc(
        'site_rating_summary',
        params: {'p_site_id': siteId},
      );
      if (raw is Map) {
        return SiteRatingSummary.fromJson(Map<String, dynamic>.from(raw));
      }
    } catch (_) {}
    return const SiteRatingSummary(avgRating: 0, reviewCount: 0);
  }

  Future<List<SiteReview>> listForSite(String siteId) async {
    final rows = await _client
        .from('site_reviews')
        .select(_reviewSelect)
        .eq('site_id', siteId)
        .order('created_at', ascending: false);

    return (rows as List)
        .map((e) => SiteReview.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<SiteReview> getById(String reviewId) async {
    final row = await _client
        .from('site_reviews')
        .select(_reviewSelect)
        .eq('id', reviewId)
        .single();
    return SiteReview.fromJson(Map<String, dynamic>.from(row));
  }

  /// Crea reseña nueva o actualiza [reviewId] si se pasa.
  Future<SiteReview> saveReview({
    required String siteId,
    required String body,
    required int rating,
    required bool isPublic,
    String? reviewId,
    List<File> newPhotos = const [],
  }) async {
    final uid = _uid;
    if (uid == null) {
      throw const AppUserError('Debes iniciar sesión.');
    }
    if (rating < 1 || rating > 5) {
      throw const AppUserError('La puntuación debe ser entre 1 y 5 estrellas.');
    }

    final Map<String, dynamic> row;
    if (reviewId == null) {
      row = await _client
          .from('site_reviews')
          .insert({
            'site_id': siteId,
            'user_id': uid,
            'body': body.trim(),
            'rating': rating,
            'is_public': isPublic,
          })
          .select(_reviewSelect)
          .single();
    } else {
      // RLS: autor o staff. No filtrar por user_id aquí (bloquea moderación).
      row = await _client
          .from('site_reviews')
          .update({
            'body': body.trim(),
            'rating': rating,
            'is_public': isPublic,
          })
          .eq('id', reviewId)
          .select(_reviewSelect)
          .single();
    }

    var review = SiteReview.fromJson(Map<String, dynamic>.from(row));
    final currentCount = review.photos.length;
    final room = maxPhotosPerReview - currentCount;
    if (newPhotos.isNotEmpty && room <= 0) {
      throw const AppUserError('Máximo 3 fotos por reseña.');
    }
    var order = currentCount;
    for (final file in newPhotos.take(room < 0 ? 0 : room)) {
      await _uploadPhoto(reviewId: review.id, file: file, sortOrder: order);
      order++;
    }
    return getById(review.id);
  }

  Future<void> _uploadPhoto({
    required String reviewId,
    required File file,
    required int sortOrder,
  }) async {
    final uid = _uid;
    if (uid == null) throw const AppUserError('Sin sesión');
    final ext = p.extension(file.path).replaceFirst('.', '').toLowerCase();
    final safeExt = ['jpg', 'jpeg', 'png', 'webp', 'heic'].contains(ext)
        ? (ext == 'jpeg' ? 'jpg' : ext)
        : 'jpg';
    final objectPath = '$uid/reviews/$reviewId/${_uuid.v4()}.$safeExt';
    final contentType = switch (safeExt) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'heic' => 'image/heic',
      _ => 'image/jpeg',
    };
    await _client.storage.from('site-photos').upload(
          objectPath,
          file,
          fileOptions: FileOptions(upsert: false, contentType: contentType),
        );
    await _client.from('site_review_photos').insert({
      'review_id': reviewId,
      'storage_path': objectPath,
      'sort_order': sortOrder,
      'uploaded_by': uid,
    });
  }

  Future<String?> signedUrl(String storagePath) async {
    try {
      return await _client.storage
          .from('site-photos')
          .createSignedUrl(storagePath, 3600);
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteMyReview(String reviewId) async {
    if (_uid == null) return;
    // RLS: autor o staff.
    await _client.from('site_reviews').delete().eq('id', reviewId);
  }

  /// Borra una foto de reseña (RLS: autor de la reseña o staff en pública).
  Future<void> deleteReviewPhoto(String photoId) async {
    if (_uid == null) {
      throw const AppUserError('Debes iniciar sesión.');
    }
    await _client.from('site_review_photos').delete().eq('id', photoId);
  }
}
