import 'package:chevere_plan/core/cache/cache_ttl.dart';
import 'package:chevere_plan/core/cache/entity_cache_store.dart';
import 'package:chevere_plan/core/cache/swr_loader.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EntityCacheStore.peekSync / SwrLoader.peekSync', () {
    test('peekSync reads memory without await', () async {
      const key = 'test_peek_sync_memory';
      final store = EntityCacheStore.instance;
      await store.write(key, {'n': 1});
      final sync = store.peekSync(key);
      expect(sync, isNotNull);
      expect(sync!.payload, isA<Map>());
      await store.invalidate(key);
    });

    test('SwrLoader.peekSync decodes within stale window', () async {
      const key = 'test_swr_peek_sync';
      final store = EntityCacheStore.instance;
      final swr = SwrLoader(store);
      await store.write(key, {
        'items': <Object?>[],
        'hasMore': false,
      });
      final peeked = swr.peekSync<Map<String, dynamic>>(
        key: key,
        ttl: CacheTtl.mySaves,
        decode: (p) => Map<String, dynamic>.from(p as Map? ?? const {}),
      );
      expect(peeked, isNotNull);
      expect(peeked!['hasMore'], false);
      await store.invalidate(key);
    });
  });
}
