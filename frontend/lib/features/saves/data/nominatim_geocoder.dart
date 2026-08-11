import 'dart:convert';

import 'package:http/http.dart' as http;

/// Resultado de búsqueda / reverse geocode (Nominatim / OSM, gratis).
class GeoPlace {
  const GeoPlace({
    required this.lat,
    required this.lng,
    this.displayName,
    this.name,
    this.city,
    this.department,
    this.addressLine,
  });

  final double lat;
  final double lng;
  final String? displayName;
  final String? name;
  final String? city;
  final String? department;
  final String? addressLine;
}

/// Nominatim (OpenStreetMap) — sin API key.
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

    final res = await _client.get(uri, headers: _headers);
    if (res.statusCode != 200) return const [];

    final list = jsonDecode(res.body);
    if (list is! List) return const [];
    return list
        .whereType<Map>()
        .map((e) => _fromNominatim(Map<String, dynamic>.from(e)))
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

    final res = await _client.get(uri, headers: _headers);
    if (res.statusCode != 200) return null;

    final map = jsonDecode(res.body);
    if (map is! Map) return null;
    return _fromNominatim(Map<String, dynamic>.from(map));
  }

  GeoPlace? _fromNominatim(Map<String, dynamic> json) {
    final lat = double.tryParse('${json['lat']}');
    final lng = double.tryParse('${json['lon']}');
    if (lat == null || lng == null) return null;

    final address = json['address'];
    Map<String, dynamic>? addr;
    if (address is Map) {
      addr = Map<String, dynamic>.from(address);
    }

    final name = _firstNonEmpty([
      json['name']?.toString(),
      addr?['tourism']?.toString(),
      addr?['amenity']?.toString(),
      addr?['shop']?.toString(),
      addr?['leisure']?.toString(),
      addr?['building']?.toString(),
    ]);

    final city = _firstNonEmpty([
      addr?['city']?.toString(),
      addr?['town']?.toString(),
      addr?['village']?.toString(),
      addr?['municipality']?.toString(),
      addr?['city_district']?.toString(),
    ]);

    final department = _firstNonEmpty([
      addr?['state']?.toString(),
      addr?['region']?.toString(),
      addr?['county']?.toString(),
    ]);

    final road = addr?['road']?.toString();
    final house = addr?['house_number']?.toString();
    final addressLine = [
      if (road != null && road.isNotEmpty) road,
      if (house != null && house.isNotEmpty) house,
    ].join(' ');

    return GeoPlace(
      lat: lat,
      lng: lng,
      displayName: json['display_name']?.toString(),
      name: name,
      city: city,
      department: department,
      addressLine: addressLine.isEmpty ? null : addressLine,
    );
  }

  String? _firstNonEmpty(List<String?> values) {
    for (final v in values) {
      if (v != null && v.trim().isNotEmpty) return v.trim();
    }
    return null;
  }
}
