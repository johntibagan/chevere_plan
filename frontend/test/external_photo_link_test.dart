import 'package:chevere_plan/core/errors/user_facing_error.dart';
import 'package:chevere_plan/features/saves/data/external_photo_link.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('requireImageUrl acepta content-type de imagen (HEAD)', () async {
    final client = MockClient((request) async {
      expect(request.method, 'HEAD');
      return http.Response(
        '',
        200,
        headers: {'content-type': 'image/jpeg'},
      );
    });
    final uri = await ExternalPhotoLinkValidator(
      httpClient: client,
    ).requireImageUrl('https://cdn.example/foto.jpg');
    expect(uri.host, 'cdn.example');
  });

  test('requireImageUrl rechaza HTML aunque el status sea 200', () async {
    var calls = 0;
    final client = MockClient((request) async {
      calls += 1;
      return http.Response(
        '<html></html>',
        200,
        headers: {'content-type': 'text/html; charset=utf-8'},
      );
    });
    await expectLater(
      ExternalPhotoLinkValidator(
        httpClient: client,
      ).requireImageUrl('https://example.com/pagina'),
      throwsA(
        isA<AppUserError>().having(
          (e) => e.message,
          'message',
          contains('no es una imagen'),
        ),
      ),
    );
    expect(calls, greaterThanOrEqualTo(1));
  });

  test('requireImageUrl prueba GET si HEAD no trae imagen', () async {
    final methods = <String>[];
    final client = MockClient((request) async {
      methods.add(request.method);
      if (request.method == 'HEAD') {
        return http.Response('', 405);
      }
      return http.Response(
        '',
        200,
        headers: {'content-type': 'image/webp'},
      );
    });
    final uri = await ExternalPhotoLinkValidator(
      httpClient: client,
    ).requireImageUrl('https://cdn.example/a.webp');
    expect(uri.path, '/a.webp');
    expect(methods, containsAll(['HEAD', 'GET']));
  });
}
