import 'package:chevere_plan/features/saves/data/google_places_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('extractChijPlaceId', () {
    expect(
      GooglePlacesClient.extractChijPlaceId(
        'https://maps.google.com/?cid=1&place_id=ChIJabcdefg',
      ),
      'ChIJabcdefg',
    );
  });

  test('cidFromFeatureId usa BigInt (CID > 64-bit signed)', () {
    expect(
      GooglePlacesClient.cidFromFeatureId(
        '0x8e4019f862f66469:0x89a875aa7db13fd7',
      ),
      '9919307554397175767',
    );
  });
}
