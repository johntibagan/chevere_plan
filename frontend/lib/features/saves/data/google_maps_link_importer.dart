import 'package:http/http.dart' as http;

import '../../../core/config/env.dart';
import 'place_geocoder.dart';

/// Resultado de importar un enlace de Google Maps.
class GoogleMapsImportResult {
  const GoogleMapsImportResult({
    this.name,
    this.lat,
    this.lng,
    this.city,
    this.department,
    this.addressLine,
    this.staticMapUrl,
    this.resolvedUrl,
  });

  final String? name;
  final double? lat;
  final double? lng;
  final String? city;
  final String? department;
  final String? addressLine;
  /// Mapa estático Geoapify (si hay coords + API key) como “imagen” del lugar.
  final String? staticMapUrl;
  final String? resolvedUrl;

  bool get hasCoords => lat != null && lng != null;
}

/// Detecta e importa datos desde enlaces de Google Maps / maps.app.goo.gl.
class GoogleMapsLinkImporter {
  GoogleMapsLinkImporter({PlaceGeocoder? geocoder, http.Client? httpClient})
      : _geocoder = geocoder ?? PlaceGeocoder(),
        _http = httpClient ?? http.Client();

  final PlaceGeocoder _geocoder;
  final http.Client _http;

  static final _urlRegex = RegExp(
    r'https?:\/\/[^\s<>"{}|\\^`\[\]]+',
    caseSensitive: false,
  );

  static bool looksLikeMapsUrl(String? text) {
    if (text == null || text.trim().isEmpty) return false;
    final v = text.toLowerCase();
    return v.contains('google.com/maps') ||
        v.contains('maps.google.') ||
        v.contains('maps.app.goo.gl') ||
        v.contains('goo.gl/maps');
  }

  /// Extrae la primera URL del texto (o el texto si ya es URL).
  static String? extractUrl(String text) {
    final m = _urlRegex.firstMatch(text.trim());
    return m?.group(0) ?? (text.trim().startsWith('http') ? text.trim() : null);
  }

  Future<GoogleMapsImportResult> importFromText(String text) async {
    final raw = extractUrl(text);
    if (raw == null) {
      throw Exception('No se encontró un enlace.');
    }
    if (!looksLikeMapsUrl(raw)) {
      throw Exception('El enlace no parece de Google Maps.');
    }

    final resolved = await _resolveFinalUrl(raw);
    final parsed = _parseMapsUrl(resolved);

    String? city = parsed.city;
    String? department = parsed.department;
    String? address = parsed.addressLine;
    var lat = parsed.lat;
    var lng = parsed.lng;
    var name = parsed.name;

    if (lat != null && lng != null) {
      try {
        final place = await _geocoder.reverse(lat: lat, lng: lng);
        if (place != null) {
          city ??= place.city;
          department ??= place.department;
          address ??= place.addressLine;
          name ??= place.name;
        }
      } catch (_) {}
    } else if (name != null && name.trim().isNotEmpty) {
      try {
        final hits = await _geocoder.search('$name Colombia', limit: 3);
        if (hits.isNotEmpty) {
          final best = hits.first;
          lat ??= best.lat;
          lng ??= best.lng;
          city ??= best.city;
          department ??= best.department;
          address ??= best.addressLine;
        }
      } catch (_) {}
    }

    return GoogleMapsImportResult(
      name: name,
      lat: lat,
      lng: lng,
      city: city,
      department: department,
      addressLine: address,
      staticMapUrl: _staticMapUrl(lat: lat, lng: lng),
      resolvedUrl: resolved.toString(),
    );
  }

  Future<Uri> _resolveFinalUrl(String raw) async {
    var uri = Uri.parse(raw);
    // Seguir redirects de goo.gl / maps.app.goo.gl (máx. 5).
    for (var i = 0; i < 5; i++) {
      final req = http.Request('GET', uri)..followRedirects = false;
      final streamed = await _http.send(req);
      final loc = streamed.headers['location'];
      if (streamed.statusCode >= 300 &&
          streamed.statusCode < 400 &&
          loc != null &&
          loc.isNotEmpty) {
        uri = uri.resolve(loc);
        continue;
      }
      // Algunos acortadores responden 200 en la URL corta; intenta HEAD via get.
      if (i == 0 && looksLikeMapsUrl(uri.toString()) && uri.host.contains('goo')) {
        try {
          final res = await _http.get(uri);
          final finalUrl = res.request?.url;
          if (finalUrl != null) uri = finalUrl;
        } catch (_) {}
      }
      break;
    }
    return uri;
  }

  GoogleMapsImportResult _parseMapsUrl(Uri uri) {
    String? name;
    double? lat;
    double? lng;
    String? address;

    // /place/Nombre/@lat,lng
    final placePath = RegExp(
      r'/place/([^/]+)/@(-?\d+\.?\d*),(-?\d+\.?\d*)',
    ).firstMatch(uri.path);
    if (placePath != null) {
      name = Uri.decodeComponent(placePath.group(1)!.replaceAll('+', ' '));
      // Quitar sufijos tipo "Name/@4.6" ya capturados; a veces el nombre trae comas.
      name = name.split('/').first.trim();
      lat = double.tryParse(placePath.group(2)!);
      lng = double.tryParse(placePath.group(3)!);
    }

    // @lat,lng,zoom en path o fragment
    if (lat == null || lng == null) {
      final at = RegExp(r'@(-?\d+\.?\d*),(-?\d+\.?\d*)')
          .firstMatch(uri.toString());
      if (at != null) {
        lat = double.tryParse(at.group(1)!);
        lng = double.tryParse(at.group(2)!);
      }
    }

    // !3dLAT!4dLNG
    if (lat == null || lng == null) {
      final d3 = RegExp(r'!3d(-?\d+\.?\d*)!4d(-?\d+\.?\d*)')
          .firstMatch(uri.toString());
      if (d3 != null) {
        lat = double.tryParse(d3.group(1)!);
        lng = double.tryParse(d3.group(2)!);
      }
    }

    final q = uri.queryParameters['q'] ??
        uri.queryParameters['query'] ??
        uri.queryParameters['destination'];
    if (q != null && q.isNotEmpty) {
      final coords = RegExp(r'^(-?\d+\.?\d*)\s*,\s*(-?\d+\.?\d*)$').firstMatch(q);
      if (coords != null) {
        lat ??= double.tryParse(coords.group(1)!);
        lng ??= double.tryParse(coords.group(2)!);
      } else {
        name ??= q;
        address ??= q;
      }
    }

    if (name == null) {
      if (uri.pathSegments.contains('place')) {
        final idx = uri.pathSegments.indexOf('place');
        if (idx >= 0 && idx + 1 < uri.pathSegments.length) {
          name = Uri.decodeComponent(
            uri.pathSegments[idx + 1].replaceAll('+', ' '),
          );
        }
      }
    }

    return GoogleMapsImportResult(
      name: name,
      lat: lat,
      lng: lng,
      addressLine: address,
    );
  }

  String? _staticMapUrl({required double? lat, required double? lng}) {
    if (lat == null || lng == null) return null;
    if (!Env.hasGeoapifyKey) return null;
    final key = Uri.encodeQueryComponent(Env.geoapifyApiKey);
    return 'https://maps.geoapify.com/v1/staticmap'
        '?style=osm-bright'
        '&width=800&height=500'
        '&center=lonlat:$lng,$lat'
        '&zoom=15'
        '&marker=lonlat:$lng,$lat;color:%23ffbb33;size:small'
        '&apiKey=$key';
  }
}
