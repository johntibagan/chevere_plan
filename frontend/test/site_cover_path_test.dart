import 'package:chevere_plan/features/saves/data/save_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('portada explícita gana sobre la primera foto', () {
    final photos = [
      {'id': 'a', 'storage_path': 'first.jpg', 'sort_order': 0, 'created_at': '2026-01-01'},
      {'id': 'b', 'storage_path': 'cover.jpg', 'sort_order': 1, 'created_at': '2026-01-02'},
    ];
    expect(
      siteCoverStoragePath(photos: photos, coverPhotoId: 'b'),
      'cover.jpg',
    );
    expect(
      siteCoverStoragePath(photos: photos, coverPhotoId: null),
      'first.jpg',
    );
  });
}
