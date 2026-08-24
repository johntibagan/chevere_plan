import 'package:chevere_plan/core/prefs/feed_layout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('FeedLayout.fromStorage default 2 columnas', () {
    expect(FeedLayout.fromStorage(null), FeedLayout.grid2);
    expect(FeedLayout.fromStorage('list').isList, isTrue);
    expect(FeedLayout.fromStorage('grid4').crossAxisCount, 4);
  });
}
