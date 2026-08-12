import 'dart:convert';

import 'package:http/http.dart' as http;

import 'geo_place.dart';

/// Reverse geocode sin API key (cliente). Fallback si Geoapify/Nominatim fallan.
class BigDataCloudGeocoder {
  BigDataCloudGeocoder({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _timeout = Duration(seconds: 8);

  Future<GeoPlace?> reverse({
    required double lat,
    required double lng,
  }) async {
    final uri = Uri.https(
      'api.bigdatacloud.net',
      '/data/reverse-geocode-client',
      {
        'latitude': '$lat',
        'longitude': '$lng',
        'localityLanguage': 'es',
      },
    );
    final res = await _client.get(uri).timeout(_timeout);
    if (res.statusCode != 200) return null;
    final body = jsonDecode(res.body);
    if (body is! Map) return null;
    return placeFromJson(Map<String, dynamic>.from(body), lat: lat, lng: lng);
  }

  /// Campos de la API: `city` / `locality` / `principalSubdivision`.
  static GeoPlace? placeFromJson(
    Map<String, dynamic> json, {
    double? lat,
    double? lng,
  }) {
    final outLat = lat ?? _asDouble(json['latitude']);
    final outLng = lng ?? _asDouble(json['longitude']);
    if (outLat == null || outLng == null) return null;

    final city = _nonEmpty(json['city']?.toString()) ??
        _nonEmpty(json['locality']?.toString());
    final department = _nonEmpty(json['principalSubdivision']?.toString());
    final address = [
      if (city != null) city,
      if (department != null) department,
    ].join(', ');

    return GeoPlace(
      lat: outLat,
      lng: outLng,
      displayName: address.isEmpty ? null : address,
      city: city,
      department: department,
      addressLine: address.isEmpty ? null : address,
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
