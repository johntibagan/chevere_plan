import 'dart:convert';

import 'package:http/http.dart' as http;

import 'geo_place.dart';

/// Nominatim (OpenStreetMap) — fallback sin API key.
/// Política: User-Agent identificable + uso moderado.
class NominatimGeocoder {
  NominatimGeocoder({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _headers = {
    'User-Agent': 'CheverePlan/1.0 (com.chevere.plan; contacto app)',
    'Accept-Language': 'es',
  };

  Future<List<GeoPlace>> search(String query, {int limit = 6}) async {
    final q = query.trim();
    if (q.length < 2) return const [];

    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': q,
      'format': 'json',
      'addressdetails': '1',
      'limit': '$limit',
      'countrycodes': 'co',
    });

    final res =
        await _client.get(uri, headers: _headers).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) return const [];

    final list = jsonDecode(res.body);
    if (list is! List) return const [];
    return list
        .whereType<Map>()
        .map((e) => placeFromJson(Map<String, dynamic>.from(e)))
        .whereType<GeoPlace>()
        .toList();
  }

  Future<GeoPlace?> reverse({required double lat, required double lng}) async {
    final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
      'lat': lat.toString(),
      'lon': lng.toString(),
      'format': 'json',
      'addressdetails': '1',
    });

    final res =
        await _client.get(uri, headers: _headers).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) return null;

    final map = jsonDecode(res.body);
    if (map is! Map) return null;
    return placeFromJson(Map<String, dynamic>.from(map));
  }

  /// Mapea la respuesta de Nominatim a [GeoPlace] (campos OSM, sin catálogos).
  static GeoPlace? placeFromJson(Map<String, dynamic> json) {
    final lat = double.tryParse('${json['lat']}');
    final lng = double.tryParse('${json['lon']}');
    if (lat == null || lng == null) return null;

    final address = json['address'];
    Map<String, dynamic>? addr;
    if (address is Map) {
      addr = Map<String, dynamic>.from(address);
    }

    final road = addr?['road']?.toString();
    final house = addr?['house_number']?.toString();
    final street = [
      if (road != null && road.trim().isNotEmpty) road.trim(),
      if (house != null && house.trim().isNotEmpty) house.trim(),
    ].join(' ');

    return GeoPlace(
      lat: lat,
      lng: lng,
      displayName: _nonEmpty(json['display_name']?.toString()),
      name: _nonEmpty(json['name']?.toString()) ??
          _nonEmpty(addr?['tourism']?.toString()) ??
          _nonEmpty(addr?['amenity']?.toString()),
      city: _nonEmpty(addr?['city']?.toString()) ??
          _nonEmpty(addr?['town']?.toString()) ??
          _nonEmpty(addr?['village']?.toString()) ??
          _nonEmpty(addr?['municipality']?.toString()),
      department: _nonEmpty(addr?['state']?.toString()),
      addressLine: street.isNotEmpty
          ? street
          : _nonEmpty(json['display_name']?.toString()),
    );
  }

  static String? _nonEmpty(String? v) {
    final t = v?.trim();
    if (t == null || t.isEmpty) return null;
    return t;
  }
}
