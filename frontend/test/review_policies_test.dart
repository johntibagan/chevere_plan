import 'package:chevere_plan/features/saves/data/site_review_models.dart';
import 'package:chevere_plan/features/saves/domain/review_policies.dart';
import 'package:flutter_test/flutter_test.dart';

SiteReview _r({
  required bool pub,
  required int rating,
  required String id,
}) {
  final t = DateTime.utc(2026, 1, 1);
  return SiteReview(
    id: id,
    siteId: 's1',
    userId: 'u1',
    body: 'x',
    rating: rating,
    isPublic: pub,
    createdAt: t,
    updatedAt: t,
  );
}

void main() {
  test('promedio ignora bitácoras privadas', () {
    final s = ReviewPolicies.summaryFrom([
      _r(pub: true, rating: 5, id: 'a'),
      _r(pub: true, rating: 3, id: 'b'),
      _r(pub: false, rating: 1, id: 'c'),
    ]);
    expect(s.reviewCount, 2);
    expect(s.avgRating, 4);
  });

  test('sin públicas → 0', () {
    final s = ReviewPolicies.summaryFrom([
      _r(pub: false, rating: 5, id: 'a'),
    ]);
    expect(s.reviewCount, 0);
    expect(s.avgRating, 0);
  });
}
