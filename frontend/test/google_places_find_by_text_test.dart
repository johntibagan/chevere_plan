import 'dart:convert';

import 'package:chevere_plan/features/saves/data/google_maps_link_importer.dart';
import 'package:chevere_plan/features/saves/data/google_places_cache.dart';
import 'package:chevere_plan/features/saves/data/google_places_client.dart';
import 'package:chevere_plan/features/saves/data/google_places_quota.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('findByText parsea places:searchText', () async {
    SharedPreferences.setMockInitialValues({});
    final client = MockClient((request) async {
      expect(request.url.path, '/v1/places:searchText');
      return http.Response(
        jsonEncode({
          'places': [
            {
              'id': 'places/ChIJtest',
              'displayName': {'text': 'Termales Los Volcanes'},
              'formattedAddress': 'Chocontá, Cundinamarca',
              'location': {'latitude': 5.0928761, 'longitude': -73.6406624},
              'addressComponents': [
                {
                  'longText': 'Chocontá',
                  'types': ['locality'],
                },
                {
                  'longText': 'Cundinamarca',
                  'types': ['administrative_area_level_1'],
                },
              ],
            },
          ],
        }),
        200,
      );
    });
    final places = GooglePlacesClient(
      httpClient: client,
      apiKey: 'test-key',
      quota: GooglePlacesQuota(),
      cache: GooglePlacesCache(),
    );
    final p = await places.findByText('Termales Los Volcanes');
    expect(p?.lat, closeTo(5.0928761, 0.00001));
    expect(p?.lng, closeTo(-73.6406624, 0.00001));
    expect(p?.city, 'Chocontá');
  });

  test('import sin pin en URL usa SearchText de Places', () async {
    SharedPreferences.setMockInitialValues({});
    final client = MockClient((request) async {
      if (request.url.host.contains('places.googleapis.com') &&
          request.url.path.contains('searchText')) {
        return http.Response(
          jsonEncode({
            'places': [
              {
                'id': 'places/ChIJtest',
                'displayName': {'text': 'Cafe Demo'},
                'formattedAddress': 'Bogotá',
                'location': {'latitude': 4.65, 'longitude': -74.05},
                'addressComponents': [
                  {
                    'longText': 'Bogotá',
                    'types': ['locality'],
                  },
                  {
                    'longText': 'Cundinamarca',
                    'types': ['administrative_area_level_1'],
                  },
                ],
              },
            ],
          }),
          200,
        );
      }
      return http.Response(
        '<html><title>Cafe Demo - Google Maps</title></html>',
        200,
      );
    });
    final places = GooglePlacesClient(
      httpClient: client,
      apiKey: 'test-key',
      quota: GooglePlacesQuota(),
      cache: GooglePlacesCache(),
    );
    final importer = GoogleMapsLinkImporter(
      httpClient: client,
      places: places,
      cache: GooglePlacesCache(),
      geocode: false,
    );
    final result = await importer.importFromText(
      'https://www.google.com/maps/place/Cafe+Demo/@4.6,-74.0,17z',
    );
    expect(result.name, isNotNull);
    expect(result.hasExactPin, isTrue);
    expect(result.lat, closeTo(4.65, 0.001));
    expect(result.lng, closeTo(-74.05, 0.001));
  });
}
