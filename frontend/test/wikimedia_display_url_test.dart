import 'package:chevere_plan/core/photos/wikimedia_display_url.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const motavita =
      'https://upload.wikimedia.org/wikipedia/commons/5/58/Motavita_parque.JPG';

  test('original Commons → thumb 500px', () {
    expect(
      wikimediaDisplayUrl(motavita, widthPx: 500),
      'https://upload.wikimedia.org/wikipedia/commons/thumb/5/58/Motavita_parque.JPG/500px-Motavita_parque.JPG',
    );
  });

  test('thumb existente se reescribe al ancho pedido', () {
    const existing =
        'https://upload.wikimedia.org/wikipedia/commons/thumb/5/58/Motavita_parque.JPG/1280px-Motavita_parque.JPG';
    expect(
      wikimediaDisplayUrl(existing, widthPx: 500),
      'https://upload.wikimedia.org/wikipedia/commons/thumb/5/58/Motavita_parque.JPG/500px-Motavita_parque.JPG',
    );
  });

  test('ancho no listado se redondea al permitido siguiente', () {
    expect(
      wikimediaDisplayUrl(motavita, widthPx: 480),
      contains('/500px-Motavita_parque.JPG'),
    );
  });

  test('URL que no es Commons queda igual', () {
    const flickr = 'https://live.staticflickr.com/123/abc_z.jpg';
    expect(wikimediaDisplayUrl(flickr, widthPx: 500), flickr);
  });

  test('cache key distingue thumb', () {
    final display = wikimediaDisplayUrl(motavita, widthPx: 500);
    expect(
      imageCacheKeyForDisplay(
        cacheKey: 'photo-1',
        sourceUrl: motavita,
        displayUrl: display,
        widthPx: 500,
      ),
      'photo-1@w500',
    );
  });

  test('original quita /thumb/', () {
    const thumb =
        'https://upload.wikimedia.org/wikipedia/commons/thumb/5/58/Motavita_parque.JPG/500px-Motavita_parque.JPG';
    expect(wikimediaOriginalUrl(thumb), motavita);
  });

  test('retry lista: preferido → siguientes → 800/500 → original', () {
    expect(
      wikimediaRetryWidths(preferredWidth: 500, fullScreen: false),
      [500, 640, 800, null],
    );
  });

  test('retry fullscreen: preferido → más grande → … → original', () {
    expect(
      wikimediaRetryWidths(preferredWidth: 1280, fullScreen: true),
      [1280, 2560, 1920, 800, 500, null],
    );
  });

  test('attempt original usa @orig', () {
    final a = wikimediaAttempt(
      sourceUrl: motavita,
      cacheKey: 'p1',
      widthPx: null,
    );
    expect(a.displayUrl, motavita);
    expect(a.cacheKey, 'p1@orig');
  });
}
