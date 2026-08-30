import 'package:chevere_plan/features/saves/data/google_maps_links.dart';
import 'package:chevere_plan/features/saves/data/navigation_apps.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const userPlace = MapsRouteStop(
    name: 'Café Demo',
    city: 'Bogotá',
    department: 'Cundinamarca',
    lat: 4.71,
    lng: -74.07,
    useExactPin: false,
    isCatalogSite: false,
  );

  const catalogPlace = MapsRouteStop(
    name: 'Plaza catálogo',
    city: 'Tunja',
    lat: 5.5,
    lng: -73.3,
    useExactPin: false,
    isCatalogSite: true,
  );

  test('geo sin punto exacto: q por nombre', () {
    final uri = NavigationApps.geoUri(userPlace);
    expect(uri.scheme, 'geo');
    expect(uri.toString(), startsWith('geo:0,0?q='));
    expect(uri.queryParameters['q'], contains('Café Demo'));
  });

  test('Waze sin punto exacto: busca por nombre', () {
    final uri = NavigationApps.wazeNavigateUri(userPlace);
    expect(uri.queryParameters['q'], contains('Café Demo'));
    expect(uri.queryParameters.containsKey('ll'), isFalse);
  });

  test('Uber: sitio de usuario con coords sí', () {
    final uri = NavigationApps.uberDropoffUri(userPlace);
    expect(uri.queryParameters['dropoff[latitude]'], '4.71');
    expect(uri.queryParameters['dropoff[nickname]'], 'Café Demo');
  });

  test('Uber: catálogo sin punto exacto — nombre, sin centroide', () {
    final uri = NavigationApps.uberDropoffUri(catalogPlace);
    expect(uri.queryParameters.containsKey('dropoff[latitude]'), isFalse);
    expect(uri.queryParameters['dropoff[nickname]'], 'Plaza catálogo');
    expect(
      uri.queryParameters['dropoff[formatted_address]'],
      contains('Plaza catálogo'),
    );
    expect(NavigationApps.coordsTrustedForRide(catalogPlace), isFalse);
  });

  test('Uber: catálogo con punto exacto sí', () {
    final uri = NavigationApps.uberDropoffUri(
      const MapsRouteStop(
        name: 'Plaza',
        lat: 5.5,
        lng: -73.3,
        useExactPin: true,
        isCatalogSite: true,
      ),
    );
    expect(uri, isNotNull);
    expect(uri.queryParameters['dropoff[latitude]'], '5.5');
  });
}
