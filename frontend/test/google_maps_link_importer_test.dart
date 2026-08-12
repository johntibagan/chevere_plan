import 'dart:convert';

import 'package:chevere_plan/features/saves/data/bigdatacloud_geocoder.dart';
import 'package:chevere_plan/features/saves/data/geoapify_geocoder.dart';
import 'package:chevere_plan/features/saves/data/google_maps_link_importer.dart';
import 'package:chevere_plan/features/saves/data/nominatim_geocoder.dart';
import 'package:chevere_plan/features/saves/data/place_geocoder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const resolved =
      'https://www.google.com/maps/place/Termales+Los+Volcanes/@5.0928814,-73.6432373,17z/data=!3m1!4b1!4m6!3m5!1s0x8e4019f862f66469:0x89a875aa7db13fd7!8m2!3d5.0928761!4d-73.6406624!16s%2Fg%2F11c3mr9lfr';

  test('parsea place + !3d!4d (coords del sitio, no del viewport)', () {
    final r = GoogleMapsLinkImporter.parseMapsUrl(Uri.parse(resolved));
    expect(r.name, 'Termales Los Volcanes');
    expect(r.lat, closeTo(5.0928761, 0.00001));
    expect(r.lng, closeTo(-73.6406624, 0.00001));
  });

  test('parseRedirectLocation entiende intent://', () {
    final next = GoogleMapsLinkImporter.parseRedirectLocation(
      Uri.parse('https://maps.app.goo.gl/abc'),
      'intent://www.google.com/maps/place/Foo/@1.0,-74.0,17z#Intent;scheme=https;end',
    );
    expect(next?.host, 'www.google.com');
    expect(next?.path, contains('/maps/place/Foo'));
  });

  test('resuelve maps.app.goo.gl vía Location 302', () async {
    final client = MockClient((request) async {
      if (request.url.host.contains('maps.app.goo.gl')) {
        return http.Response('', 302, headers: {'location': resolved});
      }
      return http.Response('', 200);
    });

    final importer = GoogleMapsLinkImporter(httpClient: client, geocode: false);
    final result = await importer.importFromText(
      'https://maps.app.goo.gl/FqEMFVek6V6Jp9737',
    );
    expect(result.name, 'Termales Los Volcanes');
    expect(result.hasCoords, isTrue);
  });

  test('Geoapify city/state del JSON de la API', () {
    final p = GeoapifyGeocoder.placeFromJson({
      'lat': 5.0928761,
      'lon': -73.6406624,
      'name': 'Termales Los Volcanes',
      'city': 'Chocontá',
      'state': 'Cundinamarca',
      'address_line1': 'Termales Los Volcanes',
      'formatted': 'Termales Los Volcanes, 250840 Chocontá, CU, Colombia',
    });
    expect(p?.name, 'Termales Los Volcanes');
    expect(p?.city, 'Chocontá');
    expect(p?.department, 'Cundinamarca');
    expect(p?.addressLine, contains('Chocontá'));
  });

  test('Nominatim town/state del JSON de OSM', () {
    final p = NominatimGeocoder.placeFromJson({
      'lat': '5.0912654',
      'lon': '-73.6407057',
      'name': 'Termales Los Volcanes',
      'address': {
        'town': 'Chocontá',
        'state': 'Cundinamarca',
        'country': 'Colombia',
      },
    });
    expect(p?.city, 'Chocontá');
    expect(p?.department, 'Cundinamarca');
  });

  test('BigDataCloud city + principalSubdivision', () {
    final p = BigDataCloudGeocoder.placeFromJson({
      'latitude': 5.0928761,
      'longitude': -73.6406624,
      'city': 'Chocontá',
      'locality': 'Chocontá',
      'principalSubdivision': 'Cundinamarca',
    });
    expect(p?.city, 'Chocontá');
    expect(p?.department, 'Cundinamarca');
    expect(p?.addressLine, 'Chocontá, Cundinamarca');
  });

  test('reverse sin Geoapify rellena ciudad vía BigDataCloud', () async {
    final client = MockClient((request) async {
      if (request.url.host.contains('bigdatacloud')) {
        return http.Response(
          jsonEncode({
            'latitude': 5.0928761,
            'longitude': -73.6406624,
            'city': 'Chocontá',
            'locality': 'Chocontá',
            'principalSubdivision': 'Cundinamarca',
          }),
          200,
        );
      }
      return http.Response('no', 403);
    });
    final geocoder = PlaceGeocoder(
      geoapify: GeoapifyGeocoder(apiKey: '', client: client),
      bigDataCloud: BigDataCloudGeocoder(client: client),
      nominatim: NominatimGeocoder(client: client),
    );
    final p = await geocoder.reverse(lat: 5.0928761, lng: -73.6406624);
    expect(p?.city, 'Chocontá');
    expect(p?.department, 'Cundinamarca');
    expect(p?.addressLine, isNotEmpty);
  });
}
