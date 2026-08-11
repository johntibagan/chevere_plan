import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/env.dart';
import 'geo_place.dart';

/// Geoapify Autocomplete + Reverse (free tier, API key, sin tarjeta).
/// Docs: https://apidocs.geoapify.com/docs/geocoding/address-autocomplete
class GeoapifyGeocoder {
  GeoapifyGeocoder({http.Client? client, String? apiKey})
      : _client = client ?? http.Client(),
        _apiKey = apiKey ?? Env.geoapifyApiKey;

  final http.Client _client;
  final String _apiKey;

  bool get isConfigured => _apiKey.isNotEmpty;

  Future<List<GeoPlace>> autocomplete(
    String query, {
    int limit = 8,
    double? biasLat,
    double? biasLng,
  }) async {
    final q = query.trim();
    if (q.length < 2 || !isConfigured) return const [];

    final params = <String, String>{
      'text': q,
      'format': 'json',
      'limit': '$limit',
      'lang': 'es',
      'filter': 'countrycode:co',
      'apiKey': _apiKey,
    };
    if (biasLat != null && biasLng != null) {
      params['bias'] = 'proximity:$biasLng,$biasLat';
    }

    final uri = Uri.https(
      'api.geoapify.com',
      '/v1/geocode/autocomplete',
      params,
    );
    final res = await _client.get(uri);
    if (res.statusCode != 200) return const [];

    final body = jsonDecode(res.body);
    final results = body is Map ? body['results'] : null;
    if (results is! List) return const [];

    return results
        .whereType<Map>()
        .map((e) => _fromGeoapify(Map<String, dynamic>.from(e)))
        .whereType<GeoPlace>()
        .toList();
  }

  Future<GeoPlace?> reverse({
    required double lat,
    required double lng,
  }) async {
    if (!isConfigured) return null;

    final uri = Uri.https('api.geoapify.com', '/v1/geocode/reverse', {
      'lat': lat.toString(),
      'lon': lng.toString(),
      'format': 'json',
      'lang': 'es',
      'apiKey': _apiKey,
    });

    final res = await _client.get(uri);
    if (res.statusCode != 200) return null;

    final body = jsonDecode(res.body);
    final results = body is Map ? body['results'] : null;
    if (results is! List || results.isEmpty) return null;
    final first = results.first;
    if (first is! Map) return null;
    return _fromGeoapify(Map<String, dynamic>.from(first));
  }

  GeoPlace? _fromGeoapify(Map<String, dynamic> json) {
    final lat = (json['lat'] as num?)?.toDouble();
    final lng = (json['lon'] as num?)?.toDouble();
    if (lat == null || lng == null) return null;

    final name = _firstNonEmpty([
      json['name']?.toString(),
      json['address_line1']?.toString(),
    ]);

    final city = _firstNonEmpty([
      json['city']?.toString(),
      json['town']?.toString(),
      json['village']?.toString(),
      json['municipality']?.toString(),
      json['county']?.toString(),
    ]);

    final department = _firstNonEmpty([
      json['state']?.toString(),
      json['region']?.toString(),
    ]);

    final addressLine = _firstNonEmpty([
      json['address_line1']?.toString(),
      [
        if (json['street'] != null) json['street'].toString(),
        if (json['housenumber'] != null) json['housenumber'].toString(),
      ].where((s) => s.isNotEmpty).join(' '),
    ]);

    final display = _firstNonEmpty([
      json['formatted']?.toString(),
      json['address_line2'] != null
          ? '${json['address_line1']}, ${json['address_line2']}'
          : null,
    ]);

    return GeoPlace(
      lat: lat,
      lng: lng,
      displayName: display,
      name: name,
      city: city,
      department: department,
      addressLine: addressLine,
    );
  }

  String? _firstNonEmpty(List<String?> values) {
    for (final v in values) {
      if (v != null && v.trim().isNotEmpty) return v.trim();
    }
    return null;
  }
}
