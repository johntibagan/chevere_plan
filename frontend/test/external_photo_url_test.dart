import 'package:chevere_plan/core/photos/external_photo_url.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('isExternalPhotoUrl solo http(s)', () {
    expect(isExternalPhotoUrl('https://example.com/a.jpg'), isTrue);
    expect(isExternalPhotoUrl('http://example.com/a.jpg'), isTrue);
    expect(isExternalPhotoUrl('uid/site/photo.jpg'), isFalse);
    expect(isExternalPhotoUrl(''), isFalse);
    expect(isExternalPhotoUrl(null), isFalse);
  });

  test('photoDisplayRef prefiere external_url', () {
    expect(
      photoDisplayRef(
        storagePath: 'uid/site/a.jpg',
        externalUrl: 'https://cdn.example/a.jpg',
      ),
      'https://cdn.example/a.jpg',
    );
    expect(
      photoDisplayRef(storagePath: 'uid/site/a.jpg', externalUrl: null),
      'uid/site/a.jpg',
    );
    expect(photoDisplayRef(storagePath: '', externalUrl: '  '), isNull);
  });

  test('contentTypeLooksLikeImage ignora charset', () {
    expect(contentTypeLooksLikeImage('image/jpeg'), isTrue);
    expect(contentTypeLooksLikeImage('image/png; charset=binary'), isTrue);
    expect(contentTypeLooksLikeImage('text/html'), isFalse);
    expect(contentTypeLooksLikeImage(null), isFalse);
  });
}
