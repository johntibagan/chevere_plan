import 'package:http/http.dart' as http;

import '../../../core/config/env.dart';
import '../../../core/errors/user_facing_error.dart';
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
  bool get hasAnything =>
      hasCoords ||
      (name != null && name!.trim().isNotEmpty) ||
      (addressLine != null && addressLine!.trim().isNotEmpty);
}

/// Detecta e importa datos desde enlaces de Google Maps / maps.app.goo.gl.
class GoogleMapsLinkImporter {
  GoogleMapsLinkImporter({
    PlaceGeocoder? geocoder,
    http.Client? httpClient,
    this.geocode = true,
  })  : _geocoder = geocoder ?? PlaceGeocoder(),
        _http = httpClient ?? http.Client();

  final PlaceGeocoder _geocoder;
  final http.Client _http;
  final bool geocode;

  static const _kMapsUa =
      'Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36';

  static const _kHeaders = {
    'User-Agent': _kMapsUa,
    'Accept': 'text/html,application/xhtml+xml;q=0.9,*/*;q=0.8',
    'Accept-Language': 'es-CO,es;q=0.9,en;q=0.8',
  };

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
      throw const AppUserError('No se encontró un enlace.');
    }
    if (!looksLikeMapsUrl(raw)) {
      throw const AppUserError('El enlace no parece de Google Maps.');
    }

    Uri resolved;
    try {
      resolved = await _resolveFinalUrl(raw);
    } catch (e) {
      if (e is AppUserError) rethrow;
      throw const AppUserError(
        'No se pudo abrir el enlace de Google Maps. Intenta de nuevo.',
      );
    }

    var parsed = parseMapsUrl(resolved);

    // Si el acortador dejó HTML (consent / interstitial), buscar URL de Maps.
    if (!parsed.hasAnything) {
      try {
        final html = await _fetchBody(resolved);
        final fromHtml = _extractMapsUriFromHtml(html);
        if (fromHtml != null) {
          resolved = fromHtml;
          parsed = parseMapsUrl(fromHtml);
        }
      } catch (_) {}
    }

    String? city = parsed.city;
    String? department = parsed.department;
    String? address = parsed.addressLine;
    var lat = parsed.lat;
    var lng = parsed.lng;
    var name = parsed.name;

    if (geocode && lat != null && lng != null) {
      try {
        final place = await _geocoder.reverse(lat: lat, lng: lng);
        if (place != null) {
          city ??= place.city;
          department ??= place.department;
          address ??= place.addressLine;
          name ??= place.name;
        }
      } catch (_) {}
    } else if (geocode && name != null && name.trim().isNotEmpty) {
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

    final result = GoogleMapsImportResult(
      name: name,
      lat: lat,
      lng: lng,
      city: city,
      department: department,
      addressLine: address,
      staticMapUrl: _staticMapUrl(lat: lat, lng: lng),
      resolvedUrl: resolved.toString(),
    );

    if (!result.hasAnything) {
      throw const AppUserError(
        'No se pudo leer ese enlace de Maps. Elige el punto en el mapa.',
      );
    }
    return result;
  }

  Future<Uri> _resolveFinalUrl(String raw) async {
    var uri = Uri.parse(raw);
    for (var i = 0; i < 8; i++) {
      final req = http.Request('GET', uri)
        ..followRedirects = false
        ..headers.addAll(_kHeaders);
      final streamed = await _http.send(req);
      final loc = streamed.headers['location'];
      try {
        await streamed.stream.drain<void>();
      } catch (_) {}

      if (streamed.statusCode >= 300 &&
          streamed.statusCode < 400 &&
          loc != null &&
          loc.isNotEmpty) {
        final next = parseRedirectLocation(uri, loc);
        if (next == null || next == uri) break;
        uri = next;
        continue;
      }
      break;
    }

    // Fallback: seguir redirects del cliente (algunos hosts no mandan Location).
    if (_isShortener(uri)) {
      try {
        final res = await _http.get(uri, headers: _kHeaders);
        final finalUrl = res.request?.url;
        if (finalUrl != null) uri = finalUrl;
        final fromHtml = _extractMapsUriFromHtml(res.body);
        if (fromHtml != null) uri = fromHtml;
      } catch (_) {}
    }
    return uri;
  }

  Future<String> _fetchBody(Uri uri) async {
    final res = await _http.get(uri, headers: _kHeaders);
    return res.body;
  }

  static bool _isShortener(Uri uri) {
    final h = uri.host.toLowerCase();
    return h.contains('goo.gl') || h.contains('maps.app.goo');
  }

  /// Convierte Location (relativa, absoluta o intent://) a URI de Maps.
  static Uri? parseRedirectLocation(Uri current, String loc) {
    var value = loc.trim();
    if (value.isEmpty) return null;
    if (value.startsWith('intent://')) {
      value = 'https://${value.substring('intent://'.length)}';
      final cut = value.split('#Intent').first;
      value = cut;
    }
    if (value.startsWith('/maps') || value.startsWith('/maps/')) {
      return Uri.parse('https://www.google.com$value');
    }
    final parsed = Uri.tryParse(value);
    if (parsed == null) return null;
    if (parsed.hasScheme) return parsed;
    return current.resolveUri(parsed);
  }

  static Uri? _extractMapsUriFromHtml(String html) {
    if (html.isEmpty) return null;
    final canonical = RegExp(
      r'''rel=["']canonical["'][^>]*href=["']([^"']+)["']''',
      caseSensitive: false,
    ).firstMatch(html);
    final href = canonical?.group(1);
    if (href != null && looksLikeMapsUrl(href)) {
      return Uri.tryParse(href);
    }
    final og = RegExp(
      r'''property=["']og:url["'][^>]*content=["']([^"']+)["']''',
      caseSensitive: false,
    ).firstMatch(html);
    final ogUrl = og?.group(1);
    if (ogUrl != null && looksLikeMapsUrl(ogUrl)) {
      return Uri.tryParse(ogUrl);
    }
    final any = RegExp(
      r'''https://(?:www\.)?google\.[^/"'\s]+/maps/[^"'\s<>]+''',
      caseSensitive: false,
    ).firstMatch(html);
    if (any != null) return Uri.tryParse(any.group(0)!);
    return null;
  }

  /// Parseo puro de una URL ya resuelta (para tests).
  static GoogleMapsImportResult parseMapsUrl(Uri uri) {
    String? name;
    double? lat;
    double? lng;
    String? address;

    // Preferir coords del lugar (!3d!4d) sobre el centro del mapa (@lat,lng).
    final d3 = RegExp(r'!3d(-?\d+\.?\d*)!4d(-?\d+\.?\d*)')
        .firstMatch(uri.toString());
    if (d3 != null) {
      lat = double.tryParse(d3.group(1)!);
      lng = double.tryParse(d3.group(2)!);
    }

    // /place/Nombre/@lat,lng
    final placePath = RegExp(
      r'/place/([^/]+)/@(-?\d+\.?\d*),(-?\d+\.?\d*)',
    ).firstMatch(uri.path);
    if (placePath != null) {
      name = _decodeName(placePath.group(1)!);
      lat ??= double.tryParse(placePath.group(2)!);
      lng ??= double.tryParse(placePath.group(3)!);
    }

    if (lat == null || lng == null) {
      final at = RegExp(r'@(-?\d+\.?\d*),(-?\d+\.?\d*)')
          .firstMatch(uri.toString());
      if (at != null) {
        lat = double.tryParse(at.group(1)!);
        lng = double.tryParse(at.group(2)!);
      }
    }

    final q = uri.queryParameters['q'] ??
        uri.queryParameters['query'] ??
        uri.queryParameters['destination'];
    if (q != null && q.isNotEmpty) {
      final coords =
          RegExp(r'^(-?\d+\.?\d*)\s*,\s*(-?\d+\.?\d*)$').firstMatch(q);
      if (coords != null) {
        lat ??= double.tryParse(coords.group(1)!);
        lng ??= double.tryParse(coords.group(2)!);
      } else {
        name ??= q;
        address ??= q;
      }
    }

    if (name == null && uri.pathSegments.contains('place')) {
      final idx = uri.pathSegments.indexOf('place');
      if (idx >= 0 && idx + 1 < uri.pathSegments.length) {
        final seg = uri.pathSegments[idx + 1];
        if (!seg.startsWith('@') && !seg.startsWith('data=')) {
          name = _decodeName(seg);
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

  static String _decodeName(String raw) {
    try {
      return Uri.decodeComponent(raw.replaceAll('+', ' ')).split('/').first.trim();
    } catch (_) {
      return raw.replaceAll('+', ' ').trim();
    }
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
