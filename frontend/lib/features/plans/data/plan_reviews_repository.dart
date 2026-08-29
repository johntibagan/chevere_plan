import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/errors/user_facing_error.dart';
import 'plan_review_models.dart';

class PlanReviewsRepository {
  PlanReviewsRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  final _uuid = const Uuid();

  static const maxPhotosPerReview = 3;

  static const _reviewSelect =
      'id, plan_id, user_id, body, created_at, updated_at, '
      'profiles!plan_reviews_user_id_fkey(username, avatar_url, google_avatar_url, use_google_avatar), '
      'plan_review_photos(id, storage_path, sort_order, created_at)';

  String? get _uid => _client.auth.currentUser?.id;

  Future<int> countForPlan(String planId) async {
    final rows = await _client
        .from('plan_reviews')
        .select('id')
        .eq('plan_id', planId);
    return (rows as List).length;
  }

  Future<List<PlanReview>> listForPlan(String planId) async {
    final rows = await _client
        .from('plan_reviews')
        .select(_reviewSelect)
        .eq('plan_id', planId)
        .order('created_at', ascending: false);

    return (rows as List)
        .map((e) => PlanReview.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<PlanReview> getById(String reviewId) async {
    final row = await _client
        .from('plan_reviews')
        .select(_reviewSelect)
        .eq('id', reviewId)
        .single();
    return PlanReview.fromJson(Map<String, dynamic>.from(row));
  }

  Future<PlanReview> saveReview({
    required String planId,
    required String body,
    String? reviewId,
    List<File> newPhotos = const [],
  }) async {
    final uid = _uid;
    if (uid == null) {
      throw const AppUserError('Debes iniciar sesión.');
    }

    final Map<String, dynamic> row;
    if (reviewId == null) {
      row = await _client
          .from('plan_reviews')
          .insert({
            'plan_id': planId,
            'user_id': uid,
            'body': body.trim(),
          })
          .select(_reviewSelect)
          .single();
    } else {
      row = await _client
          .from('plan_reviews')
          .update({'body': body.trim()})
          .eq('id', reviewId)
          .select(_reviewSelect)
          .single();
    }

    var review = PlanReview.fromJson(Map<String, dynamic>.from(row));
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
    final objectPath = '$uid/plan-reviews/$reviewId/${_uuid.v4()}.$safeExt';
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
    await _client.from('plan_review_photos').insert({
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
    await _client.from('plan_reviews').delete().eq('id', reviewId);
  }

  Future<void> deleteReviewPhoto(String photoId) async {
    if (_uid == null) {
      throw const AppUserError('Debes iniciar sesión.');
    }
    await _client.from('plan_review_photos').delete().eq('id', photoId);
  }
}
