import '../../auth/domain/profile_public_display.dart';

class PlanReviewPhoto {
  const PlanReviewPhoto({
    required this.id,
    required this.storagePath,
    this.sortOrder = 0,
    this.createdAt,
  });

  final String id;
  final String storagePath;
  final int sortOrder;
  final DateTime? createdAt;

  factory PlanReviewPhoto.fromJson(Map<String, dynamic> json) {
    final createdRaw = json['created_at'] as String?;
    return PlanReviewPhoto(
      id: json['id'] as String,
      storagePath: json['storage_path'] as String? ?? '',
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      createdAt: createdRaw != null ? DateTime.tryParse(createdRaw) : null,
    );
  }
}

class PlanReview {
  const PlanReview({
    required this.id,
    required this.planId,
    required this.userId,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    this.authorName,
    this.authorAvatarUrl,
    this.photos = const [],
  });

  final String id;
  final String planId;
  final String userId;
  final String body;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? authorName;
  final String? authorAvatarUrl;
  final List<PlanReviewPhoto> photos;

  factory PlanReview.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'];
    final parsed = ProfilePublicDisplay.fromProfileEmbed(
      profile is Map ? profile : null,
    );
    final photosRaw = json['plan_review_photos'] as List? ?? const [];
    final photos = photosRaw
        .whereType<Map>()
        .map((e) => PlanReviewPhoto.fromJson(Map<String, dynamic>.from(e)))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return PlanReview(
      id: json['id'] as String,
      planId: json['plan_id'] as String,
      userId: json['user_id'] as String,
      body: json['body'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      authorName: parsed.handle,
      authorAvatarUrl: parsed.avatarUrl,
      photos: photos,
    );
  }
}
