class SiteRatingSummary {
  const SiteRatingSummary({
    required this.avgRating,
    required this.reviewCount,
  });

  final double avgRating;
  final int reviewCount;

  factory SiteRatingSummary.fromJson(Map<String, dynamic> json) {
    return SiteRatingSummary(
      avgRating: (json['avg_rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class SiteReviewPhoto {
  const SiteReviewPhoto({
    required this.id,
    required this.storagePath,
    this.sortOrder = 0,
  });

  final String id;
  final String storagePath;
  final int sortOrder;

  factory SiteReviewPhoto.fromJson(Map<String, dynamic> json) {
    return SiteReviewPhoto(
      id: json['id'] as String,
      storagePath: json['storage_path'] as String? ?? '',
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }
}

class SiteReview {
  const SiteReview({
    required this.id,
    required this.siteId,
    required this.userId,
    required this.body,
    required this.rating,
    required this.isPublic,
    required this.createdAt,
    required this.updatedAt,
    this.authorName,
    this.authorAvatarUrl,
    this.photos = const [],
  });

  final String id;
  final String siteId;
  final String userId;
  final String body;
  final int rating;
  /// Visible en ficha / promedio si el sitio es público.
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? authorName;
  final String? authorAvatarUrl;
  final List<SiteReviewPhoto> photos;

  factory SiteReview.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'];
    String? name;
    String? avatar;
    if (profile is Map) {
      name = profile['display_name'] as String?;
      avatar = profile['avatar_url'] as String?;
    }
    final photosRaw = json['site_review_photos'] as List? ?? const [];
    final photos = photosRaw
        .whereType<Map>()
        .map((e) => SiteReviewPhoto.fromJson(Map<String, dynamic>.from(e)))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return SiteReview(
      id: json['id'] as String,
      siteId: json['site_id'] as String,
      userId: json['user_id'] as String,
      body: json['body'] as String? ?? '',
      rating: (json['rating'] as num?)?.toInt() ?? 1,
      isPublic: json['is_public'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      authorName: name,
      authorAvatarUrl: avatar,
      photos: photos,
    );
  }
}

/// Acción al detectar sitio público duplicado.
enum SameSiteAction {
  /// Vincular + reseña visible en la ficha / promedio.
  reviewPublic,

  /// Vincular + bitácora solo para mí.
  journalPrivate,

  /// Guardar de todas formas (crear sitio propio). Solo en botón Guardar.
  saveAnyway,
}

/// Resultado del picker: acción + sitio elegido (si vincula).
class SameSitePick {
  const SameSitePick({required this.action, this.siteId});

  final SameSiteAction action;
  final String? siteId;
}
