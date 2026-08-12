import 'package:chevere_plan/features/saves/data/social_place_extractor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ignora títulos genéricos de TikTok', () {
    expect(
      SocialPlaceExtractor.suggestedPlaceName(
        title: 'TikTok - Make Your Day',
        network: 'tiktok',
      ),
      isNull,
    );
  });

  test('limpia hashtags y deja el nombre del sitio', () {
    expect(
      SocialPlaceExtractor.suggestedPlaceName(
        title: 'Restaurante El Fogón #fyp #viral',
        network: 'tiktok',
      ),
      'Restaurante El Fogón',
    );
  });

  test('acepta nombre de sitio limpio', () {
    expect(
      SocialPlaceExtractor.suggestedPlaceName(
        title: 'Restaurante El Fogón Bogotá',
        network: 'tiktok',
      ),
      'Restaurante El Fogón Bogotá',
    );
  });
}
