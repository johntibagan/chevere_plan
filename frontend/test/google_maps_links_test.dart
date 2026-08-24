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
    expect(uri.queryParameters.containsKey('query_place_id'), isFalse);
  });

  test('viewPlace con useExactPin usa lat,lng, no el nombre', () {
    final uri = GoogleMapsLinks.viewPlace(
      name: 'Plaza de Bolívar',
      city: 'Tunja',
      googlePlaceId: 'ChIJtest',
      lat: 5.5,
      lng: -73.3,
      useExactPin: true,
    );
    expect(uri.queryParameters['query'], '5.5,-73.3');
    expect(uri.queryParameters.containsKey('query_place_id'), isFalse);
  });

  test('ruta de plan: origen GPS y destino por nombre, no centroide', () {
    final uri = GoogleMapsLinks.directionsFromOrigin(
      originLat: 5.54,
      originLng: -73.36,
      stopsInOrder: const [
        MapsRouteStop(
          name: 'Plaza / parque principal de Tunja',
          city: 'Tunja',
          department: 'Boyacá',
          lat: 5.53988,
          lng: -73.355539,
        ),
      ],
    );
    expect(uri.path, '/maps/dir/');
    expect(uri.queryParameters['origin'], '5.54,-73.36');
    expect(uri.queryParameters['destination'], contains('Plaza'));
    expect(uri.queryParameters['destination'], contains('Tunja'));
    expect(uri.queryParameters['destination'], isNot(contains('5.53988')));
  });

  test('ruta de plan con punto exacto usa coords en destino', () {
    final uri = GoogleMapsLinks.directionsFromOrigin(
      originLat: 5.0,
      originLng: -74.0,
      stopsInOrder: const [
        MapsRouteStop(
          name: 'Mi pin',
          lat: 5.12,
          lng: -73.45,
          useExactPin: true,
        ),
      ],
    );
    expect(uri.queryParameters['destination'], '5.12,-73.45');
  });
}
