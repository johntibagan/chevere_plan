import '../data/site_review_models.dart';

/// Promedio de ficha: solo reseñas públicas (nunca bitácoras).
abstract final class ReviewPolicies {
  static SiteRatingSummary summaryFrom(Iterable<SiteReview> reviews) {
    final pubs = reviews.where((r) => r.isPublic).toList();
    if (pubs.isEmpty) {
      return const SiteRatingSummary(avgRating: 0, reviewCount: 0);
    }
    final sum = pubs.fold<int>(0, (a, r) => a + r.rating);
    return SiteRatingSummary(
      avgRating: sum / pubs.length,
      reviewCount: pubs.length,
    );
  }
}
