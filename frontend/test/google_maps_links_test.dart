import 'package:chevere_plan/features/saves/data/google_maps_links.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('viewPlace prioriza place_id', () {
    final uri = GoogleMapsLinks.viewPlace(
      name: 'Plaza de Bolívar',
      city: 'Tunja',
      department: 'Boyacá',
      googlePlaceId: 'ChIJtest',
      lat: 5.5,
      lng: -73.3,
    );
    expect(uri.queryParameters['query_place_id'], 'ChIJtest');
    expect(uri.queryParameters['query'], contains('Plaza'));
  });

  test('viewPlace sin place_id usa nombre (no solo coords)', () {
    final uri = GoogleMapsLinks.viewPlace(
      name: 'Plaza / parque principal de Tunja',
      city: 'Tunja',
      department: 'Boyacá',
      lat: 5.5,
      lng: -73.3,
    );
    expect(uri.queryParameters['query'], contains('Tunja'));
    expect(uri.queryParameters['query'], isNot(contains('5.5')));
  });

  test('viewPlace fallback coords si no hay nombre', () {
    final uri = GoogleMapsLinks.viewPlace(
      name: '',
      lat: 5.5,
      lng: -73.3,
    );
    expect(uri.queryParameters['query'], '5.5,-73.3');
  });
}
