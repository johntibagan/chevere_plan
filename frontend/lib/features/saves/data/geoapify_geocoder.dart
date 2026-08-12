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
    final res = await _client.get(uri).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) return const [];

    final body = jsonDecode(res.body);
    final results = body is Map ? body['results'] : null;
    if (results is! List) return const [];

    return results
        .whereType<Map>()
        .map((e) => placeFromJson(Map<String, dynamic>.from(e)))
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

    final res = await _client.get(uri).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) return null;

    final body = jsonDecode(res.body);
    final raw = _firstResult(body);
    if (raw == null) return null;
    return placeFromJson(raw);
  }

  static Map<String, dynamic>? _firstResult(dynamic body) {
    if (body is! Map) return null;
    final results = body['results'];
    if (results is List && results.isNotEmpty && results.first is Map) {
      return Map<String, dynamic>.from(results.first as Map);
    }
    final features = body['features'];
    if (features is List && features.isNotEmpty && features.first is Map) {
      final feature = Map<String, dynamic>.from(features.first as Map);
      final props = feature['properties'];
      if (props is Map) return Map<String, dynamic>.from(props);
    }
    return null;
  }

  /// Mapea la respuesta de Geoapify a [GeoPlace] (campos de la API, sin catálogos).
  static GeoPlace? placeFromJson(Map<String, dynamic> json) {
    final lat = _asDouble(json['lat']);
    final lng = _asDouble(json['lon']);
    if (lat == null || lng == null) return null;

    return GeoPlace(
      lat: lat,
      lng: lng,
      displayName: _nonEmpty(json['formatted']?.toString()),
      name: _nonEmpty(json['name']?.toString()) ??
          _nonEmpty(json['address_line1']?.toString()),
      city: _nonEmpty(json['city']?.toString()) ??
          _nonEmpty(json['town']?.toString()) ??
          _nonEmpty(json['village']?.toString()) ??
          _nonEmpty(json['municipality']?.toString()),
      department: _nonEmpty(json['state']?.toString()),
      addressLine: _nonEmpty(json['formatted']?.toString()) ??
          _nonEmpty(json['address_line2']?.toString()) ??
          _nonEmpty(json['address_line1']?.toString()),
    );
  }

  static double? _asDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  static String? _nonEmpty(String? v) {
    final t = v?.trim();
    if (t == null || t.isEmpty) return null;
    return t;
  }
}
