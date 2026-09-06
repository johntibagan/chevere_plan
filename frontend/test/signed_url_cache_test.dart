import 'package:chevere_plan/core/cache/signed_url_cache.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() async {
    await SignedUrlCache.instance.clear();
  });

  test('put/get reusa en memoria', () {
    SignedUrlCache.instance.put(
      'sites/x/a.jpg',
      'https://example/signed-a',
      ttlSeconds: 3600,
    );
    expect(
      SignedUrlCache.instance.get('sites/x/a.jpg'),
      'https://example/signed-a',
    );
  });

  test('getAsync encuentra lo que put dejó en memoria', () async {
    SignedUrlCache.instance.put(
      'sites/x/b.jpg',
      'https://example/signed-b',
      ttlSeconds: 3600,
    );
    expect(
      await SignedUrlCache.instance.getAsync('sites/x/b.jpg'),
      'https://example/signed-b',
    );
  });

  test('clear borra memoria', () async {
    SignedUrlCache.instance.put(
      'sites/x/c.jpg',
      'https://example/signed-c',
      ttlSeconds: 3600,
    );
    await SignedUrlCache.instance.clear();
    expect(SignedUrlCache.instance.get('sites/x/c.jpg'), isNull);
  });

  test('evict quita una ruta', () {
    SignedUrlCache.instance.put(
      'sites/x/d.jpg',
      'https://example/signed-d',
      ttlSeconds: 3600,
    );
    SignedUrlCache.instance.evict('sites/x/d.jpg');
    expect(SignedUrlCache.instance.get('sites/x/d.jpg'), isNull);
  });
}
